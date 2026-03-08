import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const storage = admin.storage();

/**
 * Triggered when a post is deleted.
 * Cleans up related comments, likes, and storage files.
 */
export const onPostDeleted = functions.firestore
  .document('posts/{postId}')
  .onDelete(async (snapshot, context) => {
    const { postId } = context.params;
    const post = snapshot.data();

    try {
      const batch = db.batch();

      // Delete all comments for this post
      const commentsSnap = await db
        .collection('comments')
        .where('postId', '==', postId)
        .get();

      commentsSnap.docs.forEach((doc) => batch.delete(doc.ref));

      // Delete all likes for this post
      const likesSnap = await db
        .collection(`posts/${postId}/likes`)
        .get();

      likesSnap.docs.forEach((doc) => batch.delete(doc.ref));

      await batch.commit();

      // Delete storage files
      if (post['media'] && Array.isArray(post['media'])) {
        for (const mediaItem of post['media']) {
          if (mediaItem['storagePath']) {
            try {
              await storage.bucket().file(mediaItem['storagePath']).delete();
            } catch (storageError) {
              functions.logger.warn(`Could not delete file: ${mediaItem['storagePath']}`, storageError);
            }
          }
        }
      }

      functions.logger.info(`Cleaned up post ${postId}`);
    } catch (error) {
      functions.logger.error('Error in onPostDeleted:', error);
    }
  });
