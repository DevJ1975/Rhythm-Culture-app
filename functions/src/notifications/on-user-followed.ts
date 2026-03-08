import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Triggered when a user follows another user.
 * Sends a follow notification.
 */
export const onUserFollowed = functions.firestore
  .document('follows/{followId}')
  .onCreate(async (snapshot, context) => {
    const follow = snapshot.data();
    const { followerId, followingId } = follow;

    try {
      const followerSnap = await db.doc(`users/${followerId}`).get();
      if (!followerSnap.exists) return;
      const follower = followerSnap.data()!;

      const followingSnap = await db.doc(`users/${followingId}`).get();
      if (!followingSnap.exists) return;
      const following = followingSnap.data()!;

      const followerName: string = follower['artistName'] || follower['displayName'];

      // Create notification
      await db.collection('notifications').add({
        recipientId: followingId,
        senderId: followerId,
        senderName: followerName,
        senderPhotoURL: follower['photoURL'] || null,
        type: 'follow',
        title: 'New Follower',
        body: `${followerName} started following you`,
        data: {},
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Push notification
      const fcmTokens: string[] = following['fcmTokens'] || [];
      if (fcmTokens.length > 0) {
        await admin.messaging().sendEachForMulticast({
          notification: {
            title: '👤 New Follower',
            body: `${followerName} started following you`,
          },
          data: { type: 'follow', followerId, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
          tokens: fcmTokens,
        });
      }
    } catch (error) {
      functions.logger.error('Error in onUserFollowed:', error);
    }
  });
