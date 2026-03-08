import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Triggered when a message is sent in a conversation.
 * Sends a push notification to the recipient.
 */
export const onMessageSent = functions.firestore
  .document('conversations/{conversationId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const message = snapshot.data();
    const { conversationId } = context.params;
    const { senderId, text, type } = message;

    try {
      // Get conversation to find the other participant
      const convSnap = await db.doc(`conversations/${conversationId}`).get();
      if (!convSnap.exists) return;
      const conv = convSnap.data()!;

      const participantIds: string[] = conv['participantIds'];
      const recipientId = participantIds.find((id: string) => id !== senderId);
      if (!recipientId) return;

      // Get sender profile
      const senderSnap = await db.doc(`users/${senderId}`).get();
      if (!senderSnap.exists) return;
      const sender = senderSnap.data()!;
      const senderName: string = sender['artistName'] || sender['displayName'];

      // Get recipient's FCM tokens
      const recipientSnap = await db.doc(`users/${recipientId}`).get();
      if (!recipientSnap.exists) return;
      const recipient = recipientSnap.data()!;
      const fcmTokens: string[] = recipient['fcmTokens'] || [];

      const messagePreview = type === 'text'
        ? (text?.length > 50 ? text.substring(0, 50) + '...' : text)
        : type === 'image' ? '📷 Photo'
        : type === 'video' ? '🎬 Video'
        : type === 'audio' ? '🎵 Audio'
        : 'New message';

      // Create Firestore notification
      await db.collection('notifications').add({
        recipientId,
        senderId,
        senderName,
        senderPhotoURL: sender['photoURL'] || null,
        type: 'message',
        title: senderName,
        body: messagePreview,
        data: { conversationId },
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Push notification
      if (fcmTokens.length > 0) {
        await admin.messaging().sendEachForMulticast({
          notification: {
            title: `💬 ${senderName}`,
            body: messagePreview,
          },
          data: {
            type: 'message',
            conversationId,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
          apns: {
            payload: {
              aps: {
                badge: recipient['unreadMessageCount'] || 1,
                sound: 'default',
              },
            },
          },
          tokens: fcmTokens,
        });
      }
    } catch (error) {
      functions.logger.error('Error in onMessageSent:', error);
    }
  });
