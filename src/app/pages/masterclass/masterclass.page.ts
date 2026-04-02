import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonSegment, IonSegmentButton, IonLabel, IonChip, IonSkeletonText,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { starOutline, star, playCircleOutline, bookmarkOutline } from 'ionicons/icons';
import { Course } from '../../models';
import { CourseService } from '../../core/services/course.service';
import { MockDataService } from '../../core/services/mock-data.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-masterclass',
  templateUrl: './masterclass.page.html',
  styleUrls: ['./masterclass.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterModule, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonSegment, IonSegmentButton, IonLabel, IonChip, IonSkeletonText,
  ],
})
export class MasterclassPage implements OnInit {
  private courseService = inject(CourseService);
  private mockData = inject(MockDataService);

  courses: Course[] = [];
  isLoading = true;
  activeCategory = 'all';

  categories = ['all', 'Dance', 'Music', 'Vocals', 'Production', 'DJ', 'Choreography'];

  constructor() {
    addIcons({ starOutline, star, playCircleOutline, bookmarkOutline });
  }

  ngOnInit(): void {
    this.loadCourses();
  }

  async loadCourses(): Promise<void> {
    this.isLoading = true;
    try {
      if (!environment.production) {
        const cat = this.activeCategory !== 'all' ? this.activeCategory : undefined;
        this.courses = this.mockData.getCourses(cat);
        return;
      }
      const filters = this.activeCategory !== 'all' ? { category: this.activeCategory } : {};
      const result = await this.courseService.getCourses(filters as any);
      this.courses = result.courses;
    } finally {
      this.isLoading = false;
    }
  }

  async onCategoryChange(category: string): Promise<void> {
    this.activeCategory = category;
    await this.loadCourses();
  }

  formatDuration(seconds: number): string {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    if (h > 0) return `${h}h ${m}m`;
    return `${m}m`;
  }
}
