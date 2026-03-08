import { Timestamp } from '@angular/fire/firestore';
import { UserSummary, ArtistSpecialty, MusicGenre, DanceStyle } from './user.model';

export type CollaborationType =
  | 'Project'
  | 'Casting Call'
  | 'Looking For'
  | 'Studio Session'
  | 'Tour'
  | 'Music Video'
  | 'Performance'
  | 'Teaching'
  | 'Competition Team'
  | 'Other';

export type CollaborationStatus = 'open' | 'in_progress' | 'closed' | 'cancelled';

export interface Collaboration {
  id: string;
  creatorId: string;
  creator?: UserSummary;
  title: string;
  description: string;
  type: CollaborationType;
  skills: ArtistSpecialty[];
  genres?: MusicGenre[];
  danceStyles?: DanceStyle[];
  location?: string;
  city?: string;
  country?: string;
  isRemote: boolean;
  isPaid: boolean;
  compensationDetails?: string;
  applicationDeadline?: Timestamp;
  startDate?: Timestamp;
  status: CollaborationStatus;
  maxApplicants?: number;
  currentApplicants: number;
  tags: string[];
  coverImageUrl?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface CollaborationApplication {
  id: string;
  collaborationId: string;
  applicantId: string;
  applicant?: UserSummary;
  message: string;
  portfolioUrl?: string;
  status: 'pending' | 'accepted' | 'rejected';
  appliedAt: Timestamp;
  respondedAt?: Timestamp;
}
