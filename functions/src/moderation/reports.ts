import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

const REPORT_HIDE_THRESHOLD = 3; // posts hidden after 3 unique reports

/**
 * When a new report is created, count distinct reporters for the same target.
 * If we cross the threshold, hide the target until an admin reviews it.
 */
export const onReportCreated = functions.firestore
  .document('reports/{reportId}')
  .onCreate(async (snap) => {
    const report = snap.data();
    const { targetType, targetId } = report as {
      targetType: 'post' | 'comment' | 'user' | 'message' | 'event' | 'course';
      targetId: string;
    };

    try {
      const reports = await db
        .collection('reports')
        .where('targetType', '==', targetType)
        .where('targetId', '==', targetId)
        .get();

      const uniqueReporters = new Set(
        reports.docs.map((d) => d.data()['reporterId'])
      );
      if (uniqueReporters.size < REPORT_HIDE_THRESHOLD) return;

      switch (targetType) {
        case 'post':
          await db.doc(`posts/${targetId}`).update({
            isPublic: false,
            moderationStatus: 'pending_review',
          });
          break;
        case 'comment':
          await db.doc(`comments/${targetId}`).update({
            hidden: true,
            moderationStatus: 'pending_review',
          });
          break;
        case 'user':
          await db.doc(`users/${targetId}`).update({
            moderationStatus: 'pending_review',
          });
          break;
        case 'event':
          await db.doc(`events/${targetId}`).update({
            isPublished: false,
            moderationStatus: 'pending_review',
          });
          break;
        case 'course':
          await db.doc(`courses/${targetId}`).update({
            status: 'archived',
            moderationStatus: 'pending_review',
          });
          break;
      }
      functions.logger.info(
        `Auto-hid ${targetType}/${targetId} after ${uniqueReporters.size} reports`
      );
    } catch (err) {
      functions.logger.error('onReportCreated error:', err);
    }
  });

/**
 * Admin-only callable to resolve a report (approve/dismiss + restore content).
 */
export const resolveReport = functions.https.onCall(async (data, context) => {
  if (!context.auth || context.auth.token['admin'] !== true) {
    throw new functions.https.HttpsError('permission-denied', 'Admin only');
  }
  const { reportId, action, resolution } = data as {
    reportId: string;
    action: 'approve' | 'dismiss';
    resolution?: string;
  };
  const ref = db.doc(`reports/${reportId}`);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new functions.https.HttpsError('not-found', 'Report not found');
  }
  await ref.update({
    status: action === 'approve' ? 'actioned' : 'dismissed',
    reviewerId: context.auth.uid,
    reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
    resolution: resolution ?? '',
  });
  return { ok: true };
});
