import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute } from '@angular/router';
import {
  IonHeader, IonToolbar, IonContent, IonButton, IonIcon,
  IonButtons, IonList, IonItem, IonLabel, IonProgressBar, IonSpinner,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { chevronBackOutline, playCircle, lockClosed, checkmarkCircle, starOutline } from 'ionicons/icons';
import { Course, Lesson, CourseEnrollment } from '../../../models';
import { CourseService } from '../../../core/services/course.service';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-course-detail',
  templateUrl: './course-detail.page.html',
  standalone: true,
  imports: [
    CommonModule, RouterModule,
    IonHeader, IonToolbar, IonContent, IonButton, IonIcon,
    IonButtons, IonList, IonItem, IonLabel, IonProgressBar, IonSpinner,
  ],
})
export class CourseDetailPage implements OnInit {
  private courseService = inject(CourseService);
  private authService = inject(AuthService);
  private route = inject(ActivatedRoute);
  private toastCtrl = inject(ToastController);

  course: Course | null = null;
  lessons: Lesson[] = [];
  enrollment: CourseEnrollment | null = null;
  isLoading = true;
  isEnrolling = false;
  isEnrolled = false;

  constructor() {
    addIcons({ chevronBackOutline, playCircle, lockClosed, checkmarkCircle, starOutline });
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.courseService.getCourseById(id).subscribe((course) => {
      if (course) this.course = course;
    });
    this.courseService.getCourseLessons(id).subscribe((lessons) => {
      this.lessons = lessons;
      this.isLoading = false;
    });
    const uid = this.authService.currentUser?.uid;
    if (uid) {
      this.courseService.isEnrolled(id, uid).then((enrolled) => {
        this.isEnrolled = enrolled;
      });
    }
  }

  async enroll(): Promise<void> {
    if (!this.course) return;
    const uid = this.authService.currentUser?.uid;
    if (!uid) return;
    this.isEnrolling = true;
    try {
      await this.courseService.enrollInCourse(this.course.id, uid);
      this.isEnrolled = true;
      const toast = await this.toastCtrl.create({ message: 'Enrolled successfully!', duration: 2000, color: 'success', position: 'top' });
      await toast.present();
    } finally {
      this.isEnrolling = false;
    }
  }

  isLessonCompleted(lessonId: string): boolean {
    return this.enrollment?.completedLessonIds.includes(lessonId) ?? false;
  }

  formatDuration(s: number): string {
    const m = Math.floor(s / 60);
    const sec = s % 60;
    return `${m}:${sec.toString().padStart(2, '0')}`;
  }
}
