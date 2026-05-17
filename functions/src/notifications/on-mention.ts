import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

function extractMentions(text: string): string[] {
  const matches = Array.from(text.matchAll(/@([\p{L}\p{N}_.]{2,30})/gu));
  return Array.from(new Set(matches.map((m) => m[1].toLowerCase())));
}

async function notifyMentioned(
  authorId: string,
  text: string,
  context: { type: 'post' | 'comment'; postId?: string; commentId?: string }
): Promise<void> {
  const handles = extractMentions(text);
  if (handles.length === 0) return;

  const authorSnap = await db.doc(`users/${authorId}`).get();
  const author = authorSnap.data() || {};
  const authorName: string =
    author['artistName'] || author['displayName'] || 'Someone';

  // Look up users by lowercased displayName (requires displayName_lower index field)
  for (const handle of handles) {
    const q = await db
      .collection('users')
      .where('displayName_lower', '==', handle)
      .limit(1)
      .get();
    if (q.empty) continue;
    const user = q.docs[0];
    const recipientId = user.id;
    if (recipientId === authorId) continue;

    await db.collection('notifications').add({
      recipientId,
      senderId: authorId,
      senderName: authorName,
      senderPhotoURL: author['photoURL'] || null,
      type: 'mention',
      title: 'You were mentioned',
      body: `${authorName} mentioned you in a ${context.type}`,
      data: { postId: context.postId, commentId: context.commentId },
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
}

export const onPostMention = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const post = snap.data();
    const text = (post['caption'] as string) || '';
    if (!text) return;
    await notifyMentioned(post['authorId'], text, {
      type: 'post',
      postId: context.params.postId,
    });
  });

export const onCommentMention = functions.firestore
  .document('comments/{commentId}')
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const text = (comment['text'] as string) || '';
    if (!text) return;
    await notifyMentioned(comment['authorId'], text, {
      type: 'comment',
      postId: comment['postId'],
      commentId: context.params.commentId,
    });
  });
