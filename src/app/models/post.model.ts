import { Timestamp } from '@angular/fire/firestore';
import { UserSummary } from './user.model';

export type PostType = 'video' | 'image' | 'text' | 'audio';

export interface MediaItem {
  url: string;
  thumbnailUrl?: string;
  type: 'video' | 'image' | 'audio';
  duration?: number;  // seconds
  width?: number;
  height?: number;
  storagePath: string;
}

export interface Post {
  id: string;
  authorId: string;
  author?: UserSummary;
  type: PostType;
  caption?: string;
  media: MediaItem[];
  tags: string[];
  likesCount: number;
  commentsCount: number;
  sharesCount: number;
  viewsCount: number;
  isPublic: boolean;
  allowComments: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface PostLike {
  userId: string;
  postId: string;
  createdAt: Timestamp;
}

export interface Comment {
  id: string;
  postId: string;
  authorId: string;
  author?: UserSummary;
  text: string;
  likesCount: number;
  parentCommentId?: string;  // for replies
  createdAt: Timestamp;
  updatedAt?: Timestamp;
}
