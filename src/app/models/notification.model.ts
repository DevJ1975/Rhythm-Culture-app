import { Timestamp } from '@angular/fire/firestore';

export type NotificationType =
  | 'like'
  | 'comment'
  | 'follow'
  | 'message'
  | 'collab_invite'
  | 'collab_accepted'
  | 'event_reminder'
  | 'course_update'
  | 'mention'
  | 'new_post';

export interface Notification {
  id: string;
  recipientId: string;
  senderId: string;
  senderName: string;
  senderPhotoURL?: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: {
    postId?: string;
    commentId?: string;
    eventId?: string;
    courseId?: string;
    collaborationId?: string;
    conversationId?: string;
  };
  isRead: boolean;
  createdAt: Timestamp;
}
