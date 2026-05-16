/**
 * RHYTHM CULTURE - Firebase Cloud Functions
 *
 * NOTE: Replace 'path/to/serviceAccountKey.json' with your actual path
 * or use Application Default Credentials in production via Firebase Admin.
 */

import * as admin from 'firebase-admin';

// Initialize Firebase Admin
// For deployed functions, admin.initializeApp() uses Application Default Credentials automatically.
// Only use the service account approach for local development:
//
// const serviceAccount = require('path/to/serviceAccountKey.json');
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ─── Export all function modules ────────────────────────────────────────────

export * from './notifications/on-post-liked';
export * from './notifications/on-post-commented';
export * from './notifications/on-user-followed';
export * from './notifications/on-message-sent';
export * from './notifications/on-course-enrolled';
export * from './users/on-user-created';
export * from './users/on-user-deleted';
export * from './posts/on-post-deleted';
export * from './scheduled/cleanup';
export * from './admin/verification';
export * from './payments/stripe';
export * from './notifications/on-mention';
export * from './search/indexing';
export * from './scheduled/trending';
export * from './live/streaming';
export * from './moderation/reports';
export * from './scheduled/event-reminders';

export { db, messaging };
