import { Timestamp } from '@angular/fire/firestore';
import { UserSummary } from './user.model';

export interface Story {
  id: string;
  authorId: string;
  author?: UserSummary;
  mediaUrl: string;
  mediaType: 'image' | 'video';
  thumbnailUrl?: string;
  caption?: string;
  duration?: number;
  storagePath: string;
  viewersCount: number;
  expiresAt: Timestamp; // 24h after createdAt
  createdAt: Timestamp;
}

export interface StoryView {
  storyId: string;
  viewerId: string;
  viewedAt: Timestamp;
}
