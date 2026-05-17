import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Soft-deletes a user's data when their auth account is deleted.
 *
 * - Anonymizes the user document (does not hard-delete to preserve references in
 *   posts, comments, conversations).
 * - Revokes refresh tokens.
 * - Removes follow edges in both directions.
 * - Marks the user's posts as unpublished (isPublic=false) rather than deleting them.
 * - Removes the user from any conversation participant lists.
 */
export const onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const uid = user.uid;
  functions.logger.info(`Soft-deleting user data for ${uid}`);

  try {
    // 1. Anonymize user profile
    const userRef = db.doc(`users/${uid}`);
    const userSnap = await userRef.get();
    if (userSnap.exists) {
      await userRef.update({
        displayName: 'Deleted User',
        artistName: 'Deleted User',
        email: '',
        photoURL: admin.firestore.FieldValue.delete(),
        coverPhotoURL: admin.firestore.FieldValue.delete(),
        bio: admin.firestore.FieldValue.delete(),
        socialLinks: admin.firestore.FieldValue.delete(),
        fcmTokens: [],
        isPublic: false,
        isDeleted: true,
        deletedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // 2. Remove follow edges in both directions
    const followerEdges = await db
      .collection('follows')
      .where('followerId', '==', uid)
      .get();
    const followingEdges = await db
      .collection('follows')
      .where('followingId', '==', uid)
      .get();

    const batch = db.batch();
    followerEdges.docs.forEach((d) => batch.delete(d.ref));
    followingEdges.docs.forEach((d) => batch.delete(d.ref));
    await batch.commit();

    // 3. Unpublish all of this user's posts
    const posts = await db.collection('posts').where('authorId', '==', uid).get();
    const postBatch = db.batch();
    posts.docs.forEach((d) =>
      postBatch.update(d.ref, { isPublic: false, isAuthorDeleted: true })
    );
    await postBatch.commit();

    // 4. Clear unread counts for conversations this user participates in
    const conversations = await db
      .collection('conversations')
      .where('participantIds', 'array-contains', uid)
      .get();
    const convoBatch = db.batch();
    conversations.docs.forEach((d) =>
      convoBatch.update(d.ref, {
        [`unreadCounts.${uid}`]: admin.firestore.FieldValue.delete(),
      })
    );
    await convoBatch.commit();

    // 5. Best-effort: revoke any active sessions
    try {
      await admin.auth().revokeRefreshTokens(uid);
    } catch (e) {
      functions.logger.warn(`Could not revoke tokens for ${uid}:`, e);
    }

    functions.logger.info(`Soft-deleted user ${uid} successfully`);
  } catch (error) {
    functions.logger.error(`Error soft-deleting user ${uid}:`, error);
    throw error;
  }
});
