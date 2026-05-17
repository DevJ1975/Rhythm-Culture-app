import { Timestamp } from '@angular/fire/firestore';

export type ArtistSpecialty =
  | 'Dance'
  | 'Music'
  | 'Vocals'
  | 'Choreography'
  | 'DJ'
  | 'Production'
  | 'Acting'
  | 'Rap'
  | 'Beatboxing'
  | 'Modeling'
  | 'Directing'
  | 'Photography'
  | 'Videography'
  | 'Other';

export type DanceStyle =
  | 'Hip Hop'
  | 'Contemporary'
  | 'Ballet'
  | 'Salsa'
  | 'Breakdance'
  | 'Popping'
  | 'Locking'
  | 'Waacking'
  | 'Vogue'
  | 'Jazz'
  | 'Tap'
  | 'K-Pop'
  | 'Afrobeats'
  | 'Dancehall'
  | 'Krump'
  | 'Other';

export type MusicGenre =
  | 'Hip Hop'
  | 'R&B'
  | 'Pop'
  | 'Electronic'
  | 'Jazz'
  | 'Classical'
  | 'Rock'
  | 'Soul'
  | 'Gospel'
  | 'Latin'
  | 'Afrobeats'
  | 'Reggae'
  | 'Country'
  | 'Alternative'
  | 'Other';

export interface SocialLinks {
  instagram?: string;
  youtube?: string;
  tiktok?: string;
  spotify?: string;
  soundcloud?: string;
  twitter?: string;
  website?: string;
}

export interface UserProfile {
  uid: string;
  email: string;
  displayName: string;
  artistName?: string;
  photoURL?: string;
  coverPhotoURL?: string;
  bio?: string;
  location?: string;
  city?: string;
  country?: string;
  specialties: ArtistSpecialty[];
  danceStyles?: DanceStyle[];
  musicGenres?: MusicGenre[];
  socialLinks?: SocialLinks;
  followersCount: number;
  followingCount: number;
  postsCount: number;
  isVerified: boolean;
  verifiedAt?: Timestamp;
  isPro: boolean;
  proSince?: Timestamp;
  isPublic: boolean;
  isDeleted?: boolean;
  deletedAt?: Timestamp;
  // Notification preferences (per-type opt-in)
  notificationPrefs?: NotificationPreferences;
  // Stripe
  stripeCustomerId?: string;
  stripeSubscriptionId?: string;
  stripeAccountId?: string; // Connect account for instructors/organizers
  subscriptionStatus?: string;
  // Localization
  locale?: string;
  fcmTokens?: string[];
  createdAt: Timestamp;
  updatedAt: Timestamp;
  lastActiveAt?: Timestamp;
}

export interface NotificationPreferences {
  likes: boolean;
  comments: boolean;
  follows: boolean;
  messages: boolean;
  eventReminders: boolean;
  courseUpdates: boolean;
  mentions: boolean;
  marketing: boolean;
}

export const DEFAULT_NOTIFICATION_PREFS: NotificationPreferences = {
  likes: true,
  comments: true,
  follows: true,
  messages: true,
  eventReminders: true,
  courseUpdates: true,
  mentions: true,
  marketing: false,
};

export interface UserSummary {
  uid: string;
  displayName: string;
  artistName?: string;
  photoURL?: string;
  specialties: ArtistSpecialty[];
  isVerified: boolean;
}

export interface FollowRelation {
  id: string;
  followerId: string;
  followingId: string;
  createdAt: Timestamp;
}
