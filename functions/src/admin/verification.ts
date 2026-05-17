import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

function assertAdmin(context: functions.https.CallableContext): void {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Sign-in required');
  }
  if (context.auth.token['admin'] !== true) {
    throw new functions.https.HttpsError('permission-denied', 'Admin only');
  }
}

/**
 * Bootstraps the very first admin. Reads `BOOTSTRAP_ADMIN_EMAIL` from functions
 * config; if the caller's email matches and no admin exists yet, grants the claim.
 * Safe to call multiple times — only effective on first run.
 *
 * Set with: firebase functions:config:set admin.bootstrap_email="you@example.com"
 */
export const bootstrapAdmin = functions.https.onCall(async (_data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Sign-in required');
  }
  const bootstrapEmail: string | undefined = functions.config().admin?.bootstrap_email;
  if (!bootstrapEmail) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'No bootstrap email configured'
    );
  }
  if (context.auth.token.email?.toLowerCase() !== bootstrapEmail.toLowerCase()) {
    throw new functions.https.HttpsError('permission-denied', 'Email does not match');
  }
  await admin.auth().setCustomUserClaims(context.auth.uid, { admin: true });
  return { ok: true };
});

/** Grant admin claim to a user (admin-only). */
export const grantAdmin = functions.https.onCall(async (data, context) => {
  assertAdmin(context);
  const { uid } = data as { uid: string };
  if (!uid) throw new functions.https.HttpsError('invalid-argument', 'uid required');
  const existing = (await admin.auth().getUser(uid)).customClaims || {};
  await admin.auth().setCustomUserClaims(uid, { ...existing, admin: true });
  return { ok: true };
});

/** Revoke admin claim (admin-only). */
export const revokeAdmin = functions.https.onCall(async (data, context) => {
  assertAdmin(context);
  const { uid } = data as { uid: string };
  if (!uid) throw new functions.https.HttpsError('invalid-argument', 'uid required');
  const existing = (await admin.auth().getUser(uid)).customClaims || {};
  const { admin: _drop, ...rest } = existing;
  await admin.auth().setCustomUserClaims(uid, rest);
  return { ok: true };
});

/** Toggles a user's verified badge (admin-only). */
export const setUserVerified = functions.https.onCall(async (data, context) => {
  assertAdmin(context);
  const { uid, verified } = data as { uid: string; verified: boolean };
  if (!uid) throw new functions.https.HttpsError('invalid-argument', 'uid required');
  await db.doc(`users/${uid}`).update({
    isVerified: !!verified,
    verifiedAt: verified ? admin.firestore.FieldValue.serverTimestamp() : null,
    verifiedBy: verified ? context.auth!.uid : null,
  });
  return { ok: true };
});
