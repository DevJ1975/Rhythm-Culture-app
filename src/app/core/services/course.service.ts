import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  addDoc,
  getDoc,
  getDocs,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  collectionData,
  docData,
  serverTimestamp,
  increment,
  QueryDocumentSnapshot,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { Course, Lesson, CourseEnrollment } from '../../models';

@Injectable({
  providedIn: 'root',
})
export class CourseService {
  private firestore = inject(Firestore);

  // ─── Courses ──────────────────────────────────────────────────────────────────

  async getCourses(
    filters: { category?: string; level?: string; isFree?: boolean } = {},
    pageLimit = 12,
    lastDoc?: QueryDocumentSnapshot
  ): Promise<{ courses: Course[]; lastDoc: QueryDocumentSnapshot | null }> {
    const ref = collection(this.firestore, 'courses');
    let q = query(
      ref,
      where('status', '==', 'published'),
      orderBy('enrolledCount', 'desc'),
      limit(pageLimit)
    );

    if (filters.category) {
      q = query(q, where('category', '==', filters.category));
    }
    if (filters.level) {
      q = query(q, where('level', '==', filters.level));
    }
    if (filters.isFree !== undefined) {
      q = query(q, where('isFree', '==', filters.isFree));
    }
    if (lastDoc) {
      q = query(q, startAfter(lastDoc));
    }

    const snap = await getDocs(q);
    return {
      courses: snap.docs.map((d) => ({ ...d.data(), id: d.id }) as Course),
      lastDoc: snap.docs.length > 0 ? snap.docs[snap.docs.length - 1] : null,
    };
  }

  getCourseById(id: string): Observable<Course | undefined> {
    const ref = doc(this.firestore, `courses/${id}`);
    return docData(ref, { idField: 'id' }) as Observable<Course | undefined>;
  }

  // ─── Lessons ──────────────────────────────────────────────────────────────────

  getCourseLessons(courseId: string): Observable<Lesson[]> {
    const ref = collection(this.firestore, `courses/${courseId}/lessons`);
    const q = query(ref, orderBy('order', 'asc'));
    return collectionData(q, { idField: 'id' }) as Observable<Lesson[]>;
  }

  async createLesson(
    courseId: string,
    lesson: Omit<Lesson, 'id' | 'createdAt'>
  ): Promise<string> {
    const ref = collection(this.firestore, `courses/${courseId}/lessons`);
    const docRef = await addDoc(ref, {
      ...lesson,
      createdAt: serverTimestamp(),
    });

    const courseRef = doc(this.firestore, `courses/${courseId}`);
    await updateDoc(courseRef, { lessonsCount: increment(1) });

    return docRef.id;
  }

  // ─── Enrollment ───────────────────────────────────────────────────────────────

  async enrollInCourse(courseId: string, userId: string): Promise<void> {
    const enrollId = `${userId}_${courseId}`;
    const enrollRef = doc(
      this.firestore,
      `course_enrollments/${enrollId}`
    );
    const courseRef = doc(this.firestore, `courses/${courseId}`);

    const enrollment: Omit<CourseEnrollment, 'id'> = {
      courseId,
      userId,
      completedLessonIds: [],
      progressPercentage: 0,
      isCompleted: false,
      enrolledAt: serverTimestamp() as any,
    };

    await updateDoc(enrollRef, enrollment).catch(async () => {
      // Document doesn't exist, create it
      const { setDoc } = await import('@angular/fire/firestore');
      await setDoc(enrollRef, { ...enrollment, id: enrollId });
    });

    await updateDoc(courseRef, { enrolledCount: increment(1) });
  }

  async markLessonComplete(
    courseId: string,
    lessonId: string,
    userId: string,
    totalLessons: number
  ): Promise<void> {
    const enrollId = `${userId}_${courseId}`;
    const enrollRef = doc(this.firestore, `course_enrollments/${enrollId}`);
    const snap = await getDoc(enrollRef);

    if (!snap.exists()) return;

    const { arrayUnion } = await import('@angular/fire/firestore');
    const enrollment = snap.data() as CourseEnrollment;
    const completedIds = [...enrollment.completedLessonIds, lessonId];
    const progress = Math.round((completedIds.length / totalLessons) * 100);

    await updateDoc(enrollRef, {
      completedLessonIds: arrayUnion(lessonId),
      progressPercentage: progress,
      isCompleted: progress === 100,
      ...(progress === 100 ? { completedAt: serverTimestamp() } : {}),
    });
  }

  getUserEnrollments(userId: string): Observable<CourseEnrollment[]> {
    const ref = collection(this.firestore, 'course_enrollments');
    const q = query(ref, where('userId', '==', userId));
    return collectionData(q, { idField: 'id' }) as Observable<CourseEnrollment[]>;
  }

  async isEnrolled(courseId: string, userId: string): Promise<boolean> {
    const enrollId = `${userId}_${courseId}`;
    const enrollRef = doc(this.firestore, `course_enrollments/${enrollId}`);
    const snap = await getDoc(enrollRef);
    return snap.exists();
  }
}
