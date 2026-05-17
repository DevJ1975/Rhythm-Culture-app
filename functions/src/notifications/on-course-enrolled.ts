import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Triggered when a new course_enrollments document is created.
 * Notifies the instructor that a student enrolled, and bumps the course's enrolledCount.
 */
export const onCourseEnrolled = functions.firestore
  .document('course_enrollments/{enrollmentId}')
  .onCreate(async (snapshot) => {
    const enrollment = snapshot.data();
    const { courseId, userId } = enrollment;

    try {
      const courseSnap = await db.doc(`courses/${courseId}`).get();
      if (!courseSnap.exists) return;
      const course = courseSnap.data()!;
      const instructorId: string = course['instructorId'];

      const studentSnap = await db.doc(`users/${userId}`).get();
      if (!studentSnap.exists) return;
      const student = studentSnap.data()!;
      const studentName: string =
        student['artistName'] || student['displayName'] || 'A student';

      // Bump the course's enrolled count
      await db.doc(`courses/${courseId}`).update({
        enrolledCount: admin.firestore.FieldValue.increment(1),
      });

      // Don't notify if instructor enrolled in their own course
      if (instructorId === userId) return;

      const instructorSnap = await db.doc(`users/${instructorId}`).get();
      if (!instructorSnap.exists) return;
      const instructor = instructorSnap.data()!;

      await db.collection('notifications').add({
        recipientId: instructorId,
        senderId: userId,
        senderName: studentName,
        senderPhotoURL: student['photoURL'] || null,
        type: 'course_update',
        title: 'New Enrollment',
        body: `${studentName} enrolled in "${course['title']}"`,
        data: { courseId },
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      const fcmTokens: string[] = instructor['fcmTokens'] || [];
      if (fcmTokens.length > 0) {
        await admin.messaging().sendEachForMulticast({
          notification: {
            title: '🎓 New Enrollment',
            body: `${studentName} enrolled in "${course['title']}"`,
          },
          data: { type: 'course_update', courseId, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
          tokens: fcmTokens,
        });
      }
    } catch (error) {
      functions.logger.error('Error in onCourseEnrolled:', error);
    }
  });
