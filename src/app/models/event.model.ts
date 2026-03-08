import { Timestamp } from '@angular/fire/firestore';
import { UserSummary, ArtistSpecialty, MusicGenre, DanceStyle } from './user.model';

export type EventCategory =
  | 'Workshop'
  | 'Masterclass'
  | 'Battle'
  | 'Concert'
  | 'Showcase'
  | 'Camp'
  | 'Audition'
  | 'Virtual Class'
  | 'Open Mic'
  | 'Festival'
  | 'Networking'
  | 'Other';

export type EventFormat = 'in-person' | 'virtual' | 'hybrid';

export interface EventLocation {
  venue?: string;
  address?: string;
  city?: string;
  state?: string;
  country?: string;
  coordinates?: {
    lat: number;
    lng: number;
  };
  virtualLink?: string;
}

export interface Event {
  id: string;
  organizerId: string;
  organizer?: UserSummary;
  title: string;
  description: string;
  coverImageUrl?: string;
  category: EventCategory;
  format: EventFormat;
  location: EventLocation;
  eventDate: Timestamp;
  endDate?: Timestamp;
  registrationDeadline?: Timestamp;
  maxAttendees?: number;
  currentAttendees: number;
  price: number;
  currency: string;
  isFree: boolean;
  tags: string[];
  skills: ArtistSpecialty[];
  genres?: MusicGenre[];
  danceStyles?: DanceStyle[];
  isPublished: boolean;
  isCancelled: boolean;
  registrationUrl?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface EventRegistration {
  id: string;
  eventId: string;
  userId: string;
  status: 'registered' | 'waitlisted' | 'cancelled';
  paymentStatus?: 'pending' | 'completed' | 'refunded';
  registeredAt: Timestamp;
}
