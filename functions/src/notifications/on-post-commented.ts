import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Triggered when a comment is created.
 * Notifies the post author (and parent commenter for replies).
 */
export const onPostCommented = functions.firestore
  .document('comments/{commentId}')
  .onCreate(async (snapshot, context) => {
    const comment = snapshot.data();
    const { postId, authorId: commenterId, text, parentCommentId } = comment;

    try {
      // Get post
      const postSnap = await db.doc(`posts/${postId}`).get();
      if (!postSnap.exists) return;
      const post = postSnap.data()!;
      const postAuthorId: string = post['authorId'];

      // Get commenter profile
      const commenterSnap = await db.doc(`users/${commenterId}`).get();
      if (!commenterSnap.exists) return;
      const commenter = commenterSnap.data()!;
      const commenterName: string = commenter['artistName'] || commenter['displayName'];

      const notifyUsers = new Set<string>();

      // Always notify post author (unless it's their own comment)
      if (postAuthorId !== commenterId) {
        notifyUsers.add(postAuthorId);
      }

      // If it's a reply, also notify the parent commenter
      if (parentCommentId) {
        const parentSnap = await db.doc(`comments/${parentCommentId}`).get();
        if (parentSnap.exists) {
          const parentComment = parentSnap.data()!;
          if (parentComment['authorId'] !== commenterId) {
            notifyUsers.add(parentComment['authorId']);
          }
        }
      }

      const truncatedText = text.length > 50 ? text.substring(0, 50) + '...' : text;

      for (const recipientId of notifyUsers) {
        // Create Firestore notification
        await db.collection('notifications').add({
          recipientId,
          senderId: commenterId,
          senderName: commenterName,
          senderPhotoURL: commenter['photoURL'] || null,
          type: 'comment',
          title: 'New Comment',
          body: `${commenterName} commented: "${truncatedText}"`,
          data: { postId, commentId: context.params['commentId'] },
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Push notification
        const recipientSnap = await db.doc(`users/${recipientId}`).get();
        const recipient = recipientSnap.data();
        const fcmTokens: string[] = recipient?.['fcmTokens'] || [];

        if (fcmTokens.length > 0) {
          await admin.messaging().sendEachForMulticast({
            notification: {
              title: '💬 New Comment',
              body: `${commenterName}: "${truncatedText}"`,
            },
            data: { type: 'comment', postId, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
            tokens: fcmTokens,
          });
        }
      }
    } catch (error) {
      functions.logger.error('Error in onPostCommented:', error);
    }
  });
