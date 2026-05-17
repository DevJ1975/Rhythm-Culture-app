/**
 * Stripe integration — checkout, webhooks, Connect onboarding.
 *
 * Required functions config:
 *   firebase functions:config:set \
 *     stripe.secret="sk_live_..." \
 *     stripe.webhook_secret="whsec_..." \
 *     stripe.pro_price_id="price_..." \
 *     stripe.success_url="https://your.app/payment-success" \
 *     stripe.cancel_url="https://your.app/payment-cancel"
 *
 * Install: cd functions && npm install stripe
 *
 * This module imports `stripe` lazily so the rest of functions still builds
 * even if the dependency isn't installed yet.
 */
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

type StripeLike = any;

async function getStripe(): Promise<StripeLike> {
  const key = functions.config().stripe?.secret;
  if (!key) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Stripe not configured'
    );
  }
  const Stripe = (await import('stripe')).default;
  return new Stripe(key, { apiVersion: '2024-06-20' });
}

interface CheckoutData {
  kind: 'event' | 'course' | 'pro_subscription';
  itemId?: string; // eventId or courseId; required unless kind=pro_subscription
}

/**
 * Creates a Stripe Checkout session for an event, course, or Pro subscription.
 * Returns the session URL the client should redirect to.
 */
export const createCheckoutSession = functions.https.onCall(
  async (data: CheckoutData, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Sign-in required');
    }
    const stripe = await getStripe();
    const userId = context.auth.uid;
    const cfg = functions.config().stripe || {};

    const userSnap = await db.doc(`users/${userId}`).get();
    const userEmail = userSnap.data()?.['email'] || context.auth.token.email;

    const successUrl = cfg.success_url || 'https://example.com/success';
    const cancelUrl = cfg.cancel_url || 'https://example.com/cancel';

    let lineItems: any[];
    let mode: 'payment' | 'subscription';
    const metadata: Record<string, string> = { userId, kind: data.kind };

    if (data.kind === 'pro_subscription') {
      if (!cfg.pro_price_id) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Pro price not configured'
        );
      }
      lineItems = [{ price: cfg.pro_price_id, quantity: 1 }];
      mode = 'subscription';
    } else if (data.kind === 'event') {
      if (!data.itemId) {
        throw new functions.https.HttpsError('invalid-argument', 'itemId required');
      }
      const eventSnap = await db.doc(`events/${data.itemId}`).get();
      if (!eventSnap.exists) {
        throw new functions.https.HttpsError('not-found', 'Event not found');
      }
      const event = eventSnap.data()!;
      lineItems = [
        {
          price_data: {
            currency: (event['currency'] || 'usd').toLowerCase(),
            product_data: { name: event['title'] },
            unit_amount: Math.round((event['price'] || 0) * 100),
          },
          quantity: 1,
        },
      ];
      mode = 'payment';
      metadata.eventId = data.itemId;
    } else if (data.kind === 'course') {
      if (!data.itemId) {
        throw new functions.https.HttpsError('invalid-argument', 'itemId required');
      }
      const courseSnap = await db.doc(`courses/${data.itemId}`).get();
      if (!courseSnap.exists) {
        throw new functions.https.HttpsError('not-found', 'Course not found');
      }
      const course = courseSnap.data()!;
      lineItems = [
        {
          price_data: {
            currency: (course['currency'] || 'usd').toLowerCase(),
            product_data: { name: course['title'] },
            unit_amount: Math.round((course['price'] || 0) * 100),
          },
          quantity: 1,
        },
      ];
      mode = 'payment';
      metadata.courseId = data.itemId;
    } else {
      throw new functions.https.HttpsError('invalid-argument', 'Unknown kind');
    }

    const session = await stripe.checkout.sessions.create({
      mode,
      payment_method_types: ['card'],
      line_items: lineItems,
      customer_email: userEmail,
      success_url: successUrl + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: cancelUrl,
      metadata,
    });

    return { sessionId: session.id, url: session.url };
  }
);

/**
 * Stripe webhook receiver. Handles checkout.session.completed and subscription events.
 * Configure the endpoint in the Stripe dashboard and set stripe.webhook_secret.
 */
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const cfg = functions.config().stripe || {};
  if (!cfg.secret || !cfg.webhook_secret) {
    res.status(503).send('Stripe not configured');
    return;
  }

  const stripe = await getStripe();
  const sig = req.headers['stripe-signature'] as string;
  let event: any;
  try {
    event = stripe.webhooks.constructEvent(
      (req as any).rawBody,
      sig,
      cfg.webhook_secret
    );
  } catch (err: any) {
    functions.logger.error('Webhook signature failed:', err.message);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object;
        const md = session.metadata || {};
        const userId = md.userId as string;
        if (!userId) break;

        if (md.kind === 'event' && md.eventId) {
          await db.collection('event_registrations').add({
            eventId: md.eventId,
            userId,
            status: 'registered',
            paymentStatus: 'completed',
            stripeSessionId: session.id,
            amount: session.amount_total / 100,
            currency: session.currency,
            registeredAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          await db.doc(`events/${md.eventId}`).update({
            currentAttendees: admin.firestore.FieldValue.increment(1),
          });
        } else if (md.kind === 'course' && md.courseId) {
          await db.collection('course_enrollments').add({
            courseId: md.courseId,
            userId,
            completedLessonIds: [],
            progressPercentage: 0,
            isCompleted: false,
            stripeSessionId: session.id,
            amount: session.amount_total / 100,
            currency: session.currency,
            enrolledAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else if (md.kind === 'pro_subscription') {
          await db.doc(`users/${userId}`).update({
            isPro: true,
            stripeCustomerId: session.customer,
            stripeSubscriptionId: session.subscription,
            proSince: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        break;
      }
      case 'customer.subscription.deleted':
      case 'customer.subscription.updated': {
        const sub = event.data.object;
        const customerId = sub.customer;
        const q = await db
          .collection('users')
          .where('stripeCustomerId', '==', customerId)
          .limit(1)
          .get();
        if (q.empty) break;
        const userRef = q.docs[0].ref;
        const active = ['active', 'trialing'].includes(sub.status);
        await userRef.update({
          isPro: active,
          subscriptionStatus: sub.status,
        });
        break;
      }
      default:
        // ignore others
        break;
    }
    res.status(200).send({ received: true });
  } catch (err: any) {
    functions.logger.error('Webhook handler error:', err);
    res.status(500).send('Server error');
  }
});

/**
 * Stripe Connect — creates an Express account for an instructor/organizer and
 * returns an onboarding URL.
 */
export const createConnectOnboarding = functions.https.onCall(
  async (_data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Sign-in required');
    }
    const stripe = await getStripe();
    const userId = context.auth.uid;
    const userRef = db.doc(`users/${userId}`);
    const userSnap = await userRef.get();
    const user = userSnap.data() || {};

    let accountId: string = user['stripeAccountId'];
    if (!accountId) {
      const account = await stripe.accounts.create({
        type: 'express',
        email: user['email'] || context.auth.token.email,
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
      });
      accountId = account.id;
      await userRef.update({ stripeAccountId: accountId });
    }

    const cfg = functions.config().stripe || {};
    const accountLink = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: (cfg.connect_refresh_url as string) || 'https://example.com/connect/refresh',
      return_url: (cfg.connect_return_url as string) || 'https://example.com/connect/return',
      type: 'account_onboarding',
    });

    return { url: accountLink.url };
  }
);
