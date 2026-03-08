import { Timestamp } from '@angular/fire/firestore';
import { UserSummary } from './user.model';

export type MessageType = 'text' | 'image' | 'video' | 'audio' | 'post_share';

export interface Message {
  id: string;
  conversationId: string;
  senderId: string;
  sender?: UserSummary;
  type: MessageType;
  text?: string;
  mediaUrl?: string;
  mediaThumbnail?: string;
  sharedPostId?: string;
  isRead: boolean;
  isDeleted: boolean;
  createdAt: Timestamp;
  updatedAt?: Timestamp;
}

export interface Conversation {
  id: string;
  participantIds: string[];
  participants?: UserSummary[];
  lastMessage?: string;
  lastMessageAt?: Timestamp;
  lastMessageSenderId?: string;
  unreadCounts: { [userId: string]: number };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
