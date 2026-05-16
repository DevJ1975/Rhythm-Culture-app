import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { hasOptedIn } from '../notifications/_prefs';

const db = admin.firestore();

/**
 * Hourly: find events starting in 23-25 hours and notify registered attendees.
 * Uses a `remindersSent` flag to avoid double-notifying.
 */
export const sendEventReminders = functions.pubsub
  .schedule('every 60 minutes')
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();
    const in23h = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + 23 * 60 * 60 * 1000
    );
    const in25h = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + 25 * 60 * 60 * 1000
    );

    const events = await db
      .collection('events')
      .where('eventDate', '>=', in23h)
      .where('eventDate', '<=', in25h)
      .where('isCancelled', '==', false)
      .where('remindersSent', '==', false)
      .limit(100)
      .get();

    for (const eventDoc of events.docs) {
      const event = eventDoc.data();
      const eventId = eventDoc.id;
      try {
        const regs = await db
          .collection('event_registrations')
          .where('eventId', '==', eventId)
          .where('status', '==', 'registered')
          .get();

        for (const reg of regs.docs) {
          const userId = reg.data()['userId'];
          if (!(await hasOptedIn(userId, 'eventReminders'))) continue;

          await db.collection('notifications').add({
            recipientId: userId,
            senderId: event['organizerId'],
            senderName: event['title'],
            senderPhotoURL: event['coverImageUrl'] || null,
            type: 'event_reminder',
            title: 'Upcoming event',
            body: `"${event['title']}" starts tomorrow`,
            data: { eventId },
            isRead: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          const userSnap = await db.doc(`users/${userId}`).get();
          const fcmTokens: string[] = userSnap.data()?.['fcmTokens'] || [];
          if (fcmTokens.length > 0) {
            await admin.messaging().sendEachForMulticast({
              notification: {
                title: 'Upcoming event',
                body: `"${event['title']}" starts tomorrow`,
              },
              data: { type: 'event_reminder', eventId },
              tokens: fcmTokens,
            });
          }
        }

        await eventDoc.ref.update({ remindersSent: true });
      } catch (err) {
        functions.logger.error(`Event reminder for ${eventId} failed:`, err);
      }
    }
  });
