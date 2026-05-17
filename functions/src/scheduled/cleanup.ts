import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Scheduled function to clean up old, read notifications.
 * Runs every Sunday at midnight UTC.
 */
export const cleanupOldNotifications = functions.pubsub
  .schedule('every sunday 00:00')
  .timeZone('UTC')
  .onRun(async () => {
    // Delete notifications older than 30 days that have been read
    const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    );

    try {
      const snap = await db
        .collection('notifications')
        .where('isRead', '==', true)
        .where('createdAt', '<', thirtyDaysAgo)
        .limit(500)
        .get();

      if (snap.empty) {
        functions.logger.info('No old notifications to clean up');
        return;
      }

      const batch = db.batch();
      snap.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();

      functions.logger.info(`Deleted ${snap.size} old notifications`);
    } catch (error) {
      functions.logger.error('Error in cleanupOldNotifications:', error);
    }
  });

/**
 * Scheduled function to update trending posts.
 * Runs daily.
 */
export const updateTrendingPosts = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async () => {
    try {
      const twentyFourHoursAgo = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - 24 * 60 * 60 * 1000)
      );

      const snap = await db
        .collection('posts')
        .where('isPublic', '==', true)
        .where('createdAt', '>', twentyFourHoursAgo)
        .orderBy('createdAt', 'desc')
        .limit(50)
        .get();

      // Calculate trending score: likes * 3 + comments * 2 + shares
      const posts = snap.docs.map((doc) => {
        const data = doc.data();
        const score =
          (data['likesCount'] || 0) * 3 +
          (data['commentsCount'] || 0) * 2 +
          (data['sharesCount'] || 0);
        return { id: doc.id, score };
      });

      posts.sort((a, b) => b.score - a.score);

      // Store top trending posts in a special collection
      const trendingRef = db.doc('meta/trending');
      await trendingRef.set({
        postIds: posts.slice(0, 20).map((p) => p.id),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info('Updated trending posts');
    } catch (error) {
      functions.logger.error('Error in updateTrendingPosts:', error);
    }
  });

/**
 * Scheduled function to delete expired stories (>24h old).
 * Runs hourly.
 */
export const cleanupExpiredStories = functions.pubsub
  .schedule('every 60 minutes')
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();
    try {
      const snap = await db
        .collection('stories')
        .where('expiresAt', '<', now)
        .limit(500)
        .get();
      if (snap.empty) return;

      const storage = admin.storage().bucket();
      for (const docSnap of snap.docs) {
        const story = docSnap.data();
        // Delete viewer subcollection
        const views = await docSnap.ref.collection('views').get();
        const batch = db.batch();
        views.docs.forEach((v) => batch.delete(v.ref));
        batch.delete(docSnap.ref);
        await batch.commit();

        // Delete media from storage
        if (story['storagePath']) {
          try {
            await storage.file(story['storagePath']).delete();
          } catch (e) {
            functions.logger.warn(
              `Could not delete storage path ${story['storagePath']}:`,
              e
            );
          }
        }
      }
      functions.logger.info(`Cleaned up ${snap.size} expired stories`);
    } catch (error) {
      functions.logger.error('Error in cleanupExpiredStories:', error);
    }
  });
