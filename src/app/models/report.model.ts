import { Timestamp } from '@angular/fire/firestore';

export type ReportTargetType = 'post' | 'comment' | 'user' | 'message' | 'event' | 'course';
export type ReportReason =
  | 'spam'
  | 'harassment'
  | 'hate_speech'
  | 'nudity'
  | 'violence'
  | 'misinformation'
  | 'intellectual_property'
  | 'other';
export type ReportStatus = 'open' | 'reviewing' | 'actioned' | 'dismissed';

export interface Report {
  id: string;
  reporterId: string;
  targetType: ReportTargetType;
  targetId: string;
  reason: ReportReason;
  details?: string;
  status: ReportStatus;
  reviewerId?: string;
  reviewedAt?: Timestamp;
  resolution?: string;
  createdAt: Timestamp;
}

export interface Block {
  id: string;
  blockerId: string;
  blockedId: string;
  createdAt: Timestamp;
}
