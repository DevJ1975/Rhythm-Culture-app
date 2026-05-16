import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Rebuilds `meta/trending` every hour by scoring posts created in the last 48h.
 *
 * Score = likes + 2*comments + 3*shares, decayed by hours since creation.
 */
export const rebuildTrending = functions.pubsub
  .schedule('every 60 minutes')
  .onRun(async () => {
    const since = admin.firestore.Timestamp.fromMillis(
      Date.now() - 48 * 60 * 60 * 1000
    );
    const snap = await db
      .collection('posts')
      .where('isPublic', '==', true)
      .where('createdAt', '>=', since)
      .limit(500)
      .get();

    const scored = snap.docs
      .map((d) => {
        const data = d.data();
        const createdAt = (data['createdAt'] as admin.firestore.Timestamp) ||
          admin.firestore.Timestamp.now();
        const ageHours = Math.max(
          1,
          (Date.now() - createdAt.toMillis()) / (60 * 60 * 1000)
        );
        const raw =
          (data['likesCount'] || 0) +
          2 * (data['commentsCount'] || 0) +
          3 * (data['sharesCount'] || 0) +
          0.5 * (data['viewsCount'] || 0);
        return {
          id: d.id,
          score: raw / Math.pow(ageHours, 1.5),
          authorId: data['authorId'],
          type: data['type'],
          createdAt,
        };
      })
      .sort((a, b) => b.score - a.score)
      .slice(0, 50);

    await db.doc('meta/trending').set({
      posts: scored,
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Trending hashtags — top 20 from the hashtags collection
    const tagSnap = await db
      .collection('hashtags')
      .orderBy('count', 'desc')
      .limit(20)
      .get();
    await db.doc('meta/trending_tags').set({
      tags: tagSnap.docs.map((d) => d.data()),
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
