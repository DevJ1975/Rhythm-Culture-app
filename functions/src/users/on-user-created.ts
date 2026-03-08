import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Triggered when a new Firebase Auth user is created.
 * Sets up the initial user profile if not already created by the client.
 */
export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName, photoURL } = user;

  try {
    const userRef = db.doc(`users/${uid}`);
    const snap = await userRef.get();

    // Only create if the profile doesn't already exist
    // (it may have been created by the client in registerWithEmail)
    if (!snap.exists) {
      const now = admin.firestore.FieldValue.serverTimestamp();
      await userRef.set({
        uid,
        email: email || '',
        displayName: displayName || email?.split('@')[0] || 'Artist',
        artistName: displayName || email?.split('@')[0] || 'Artist',
        photoURL: photoURL || null,
        specialties: [],
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        isVerified: false,
        isPro: false,
        isPublic: true,
        fcmTokens: [],
        createdAt: now,
        updatedAt: now,
        lastActiveAt: now,
      });
      functions.logger.info(`Created profile for user: ${uid}`);
    }
  } catch (error) {
    functions.logger.error('Error in onUserCreated:', error);
  }
});

/**
 * Triggered when a Firebase Auth user is deleted.
 * Cleans up user data.
 */
export const onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const { uid } = user;
  try {
    // Mark user as deleted (soft delete) instead of removing data immediately
    await db.doc(`users/${uid}`).update({
      isDeleted: true,
      deletedAt: admin.firestore.FieldValue.serverTimestamp(),
      email: 'deleted@rhythmculture.app',
      displayName: 'Deleted User',
      photoURL: null,
    });
    functions.logger.info(`Soft-deleted user: ${uid}`);
  } catch (error) {
    functions.logger.error('Error in onUserDeleted:', error);
  }
});
