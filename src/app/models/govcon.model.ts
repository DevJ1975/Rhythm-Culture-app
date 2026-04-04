import { Timestamp } from '@angular/fire/firestore';
import { ArtistSpecialty } from './user.model';

// ── Types ──────────────────────────────────────────────────────────────────

export type OpportunityType =
  | 'Presolicitation'
  | 'Solicitation'
  | 'Combined Synopsis'
  | 'Sources Sought'
  | 'Award Notice'
  | 'Special Notice';

export type SetAside =
  | 'Small Business'
  | '8(a)'
  | 'HUBZone'
  | 'SDVOSB'
  | 'WOSB'
  | 'None';

export type BidStatus =
  | 'tracking'
  | 'preparing'
  | 'submitted'
  | 'won'
  | 'lost'
  | 'no_bid';

export type OpportunityStatus = 'active' | 'closed' | 'awarded' | 'cancelled';

export type SamRegistrationStatus = 'active' | 'expiring' | 'expired' | 'not_registered';

// ── Interfaces ─────────────────────────────────────────────────────────────

export interface GovConOpportunity {
  id: string;
  samOpportunityId?: string;
  title: string;
  solicitationNumber?: string;
  type: OpportunityType;
  agency: string;
  office?: string;
  description: string;
  naicsCodes: string[];
  setAside: SetAside;
  postedDate: Timestamp;
  responseDeadline: Timestamp;
  estimatedValue?: number;
  placeOfPerformance?: {
    city?: string;
    state?: string;
    country?: string;
  };
  pointOfContact?: {
    name?: string;
    email?: string;
    phone?: string;
  };
  attachmentUrls?: string[];
  status: OpportunityStatus;
  matchedSpecialties?: ArtistSpecialty[];
  syncedAt?: Timestamp;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface GovConOpportunitySummary {
  id: string;
  title: string;
  agency: string;
  responseDeadline: Timestamp;
  setAside: SetAside;
}

export interface GovConBid {
  id: string;
  opportunityId: string;
  opportunity?: GovConOpportunitySummary;
  userId: string;
  status: BidStatus;
  bidAmount?: number;
  estimatedCost?: number;
  dueDate?: Timestamp;
  submittedAt?: Timestamp;
  teamMemberIds?: string[];
  notes?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface PastPerformance {
  agency: string;
  contractNumber?: string;
  value?: number;
  periodStart?: Timestamp;
  periodEnd?: Timestamp;
  description: string;
}

export interface GovConProfile {
  userId: string;
  ueiNumber?: string;
  cageCode?: string;
  naicsCodes: string[];
  samRegistrationStatus: SamRegistrationStatus;
  samExpirationDate?: Timestamp;
  setAsideEligibility: SetAside[];
  pastPerformance: PastPerformance[];
  capabilitySummary?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface GovConSavedSearch {
  id: string;
  userId: string;
  name: string;
  keywords?: string[];
  naicsCodes?: string[];
  setAsides?: SetAside[];
  agencies?: string[];
  states?: string[];
  notifyOnMatch: boolean;
  lastRunAt?: Timestamp;
  createdAt: Timestamp;
}

// ── NAICS Reference ────────────────────────────────────────────────────────

export const PERFORMING_ARTS_NAICS: { code: string; description: string }[] = [
  { code: '711110', description: 'Theater Companies and Dinner Theaters' },
  { code: '711120', description: 'Dance Companies' },
  { code: '711130', description: 'Musical Groups and Artists' },
  { code: '711190', description: 'Other Performing Arts Companies' },
  { code: '711310', description: 'Promoters with Facilities' },
  { code: '711320', description: 'Promoters without Facilities' },
  { code: '611610', description: 'Fine Arts Schools' },
  { code: '512110', description: 'Motion Picture Production' },
  { code: '512240', description: 'Sound Recording Studios' },
];
