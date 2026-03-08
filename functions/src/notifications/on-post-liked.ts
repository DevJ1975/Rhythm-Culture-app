import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Triggered when a user likes a post.
 * Creates a notification for the post author and sends a push notification.
 */
export const onPostLiked = functions.firestore
  .document('posts/{postId}/likes/{userId}')
  .onCreate(async (snapshot, context) => {
    const { postId, userId: likerId } = context.params;

    try {
      // Get the post to find the author
      const postSnap = await db.doc(`posts/${postId}`).get();
      if (!postSnap.exists) return;

      const post = postSnap.data()!;
      const authorId: string = post['authorId'];

      // Don't notify if user liked their own post
      if (authorId === likerId) return;

      // Get the liker's profile
      const likerSnap = await db.doc(`users/${likerId}`).get();
      if (!likerSnap.exists) return;
      const liker = likerSnap.data()!;

      // Get the author's profile for FCM tokens
      const authorSnap = await db.doc(`users/${authorId}`).get();
      if (!authorSnap.exists) return;
      const author = authorSnap.data()!;

      // Create Firestore notification
      await db.collection('notifications').add({
        recipientId: authorId,
        senderId: likerId,
        senderName: liker['artistName'] || liker['displayName'],
        senderPhotoURL: liker['photoURL'] || null,
        type: 'like',
        title: 'New Like',
        body: `${liker['artistName'] || liker['displayName']} liked your post`,
        data: { postId },
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Send push notification if author has FCM tokens
      const fcmTokens: string[] = author['fcmTokens'] || [];
      if (fcmTokens.length === 0) return;

      const message: admin.messaging.MulticastMessage = {
        notification: {
          title: '❤️ New Like',
          body: `${liker['artistName'] || liker['displayName']} liked your post`,
        },
        data: {
          type: 'like',
          postId,
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        tokens: fcmTokens,
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      await cleanupInvalidTokens(authorId, fcmTokens, response);
    } catch (error) {
      functions.logger.error('Error in onPostLiked:', error);
    }
  });

async function cleanupInvalidTokens(
  userId: string,
  tokens: string[],
  response: admin.messaging.BatchResponse
): Promise<void> {
  const invalidTokens: string[] = [];
  response.responses.forEach((resp, idx) => {
    if (!resp.success && (
      resp.error?.code === 'messaging/invalid-registration-token' ||
      resp.error?.code === 'messaging/registration-token-not-registered'
    )) {
      invalidTokens.push(tokens[idx]);
    }
  });

  if (invalidTokens.length > 0) {
    await db.doc(`users/${userId}`).update({
      fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
    });
  }
}
