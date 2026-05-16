import * as admin from 'firebase-admin';

const db = admin.firestore();

export type PrefKey =
  | 'likes'
  | 'comments'
  | 'follows'
  | 'messages'
  | 'eventReminders'
  | 'courseUpdates'
  | 'mentions'
  | 'marketing';

const DEFAULTS: Record<PrefKey, boolean> = {
  likes: true,
  comments: true,
  follows: true,
  messages: true,
  eventReminders: true,
  courseUpdates: true,
  mentions: true,
  marketing: false,
};

/**
 * Returns whether the given recipient has opted in to a given notification type.
 * Falls back to sensible defaults when prefs are missing.
 */
export async function hasOptedIn(userId: string, key: PrefKey): Promise<boolean> {
  const snap = await db.doc(`users/${userId}`).get();
  if (!snap.exists) return false;
  const prefs = (snap.data()?.notificationPrefs || {}) as Record<string, boolean>;
  return prefs[key] ?? DEFAULTS[key];
}

/**
 * Returns whether the recipient has blocked the sender.
 */
export async function isBlocked(
  recipientId: string,
  senderId: string
): Promise<boolean> {
  const blockId = `${recipientId}_${senderId}`;
  const snap = await db.doc(`blocks/${blockId}`).get();
  return snap.exists;
}
