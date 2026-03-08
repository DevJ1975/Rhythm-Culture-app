import { Timestamp } from '@angular/fire/firestore';
import { UserSummary, ArtistSpecialty, MusicGenre, DanceStyle } from './user.model';

export type CourseLevel = 'beginner' | 'intermediate' | 'advanced' | 'all-levels';
export type CourseStatus = 'draft' | 'published' | 'archived';
export type LessonType = 'video' | 'live' | 'text' | 'quiz';

export interface Lesson {
  id: string;
  courseId: string;
  title: string;
  description?: string;
  type: LessonType;
  videoUrl?: string;
  thumbnailUrl?: string;
  duration?: number;  // seconds
  order: number;
  isFree: boolean;
  liveStreamUrl?: string;
  liveStreamScheduledAt?: Timestamp;
  createdAt: Timestamp;
}

export interface Course {
  id: string;
  instructorId: string;
  instructor?: UserSummary;
  title: string;
  subtitle?: string;
  description: string;
  coverImageUrl?: string;
  previewVideoUrl?: string;
  category: ArtistSpecialty;
  subcategory?: string;
  level: CourseLevel;
  danceStyles?: DanceStyle[];
  musicGenres?: MusicGenre[];
  tags: string[];
  language: string;
  price: number;
  currency: string;
  isFree: boolean;
  lessonsCount: number;
  totalDuration: number;  // seconds
  enrolledCount: number;
  rating: number;
  ratingsCount: number;
  status: CourseStatus;
  requirements?: string[];
  whatYouLearn?: string[];
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface CourseEnrollment {
  id: string;
  courseId: string;
  userId: string;
  completedLessonIds: string[];
  progressPercentage: number;
  isCompleted: boolean;
  enrolledAt: Timestamp;
  completedAt?: Timestamp;
}

export interface CourseReview {
  id: string;
  courseId: string;
  userId: string;
  rating: number;
  review?: string;
  createdAt: Timestamp;
}
