import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  addDoc,
  getDocs,
  updateDoc,
  deleteDoc,
  setDoc,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  collectionData,
  docData,
  serverTimestamp,
  QueryDocumentSnapshot,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import {
  GovConOpportunity,
  GovConBid,
  GovConProfile,
  GovConSavedSearch,
  BidStatus,
  SetAside,
} from '../../models';
import { environment } from '../../../environments/environment';
import { MockDataService } from './mock-data.service';

@Injectable({
  providedIn: 'root',
})
export class GovConService {
  private firestore = inject(Firestore);
  private mockData = inject(MockDataService);

  // ─── Opportunities ───────────────────────────────────────────────────────────

  async getOpportunities(
    filters: {
      naicsCode?: string;
      setAside?: SetAside;
      keyword?: string;
      status?: string;
    } = {},
    pageLimit = 20,
    lastDoc?: QueryDocumentSnapshot
  ): Promise<{ opportunities: GovConOpportunity[]; lastDoc: QueryDocumentSnapshot | null }> {
    if (environment.samGov.useMockData) {
      let opps = this.mockData.getGovConOpportunities();
      if (filters.naicsCode) {
        opps = opps.filter(o => o.naicsCodes.includes(filters.naicsCode!));
      }
      if (filters.setAside && filters.setAside !== 'None') {
        opps = opps.filter(o => o.setAside === filters.setAside);
      }
      if (filters.keyword) {
        const kw = filters.keyword.toLowerCase();
        opps = opps.filter(o =>
          o.title.toLowerCase().includes(kw) || o.description.toLowerCase().includes(kw)
        );
      }
      return { opportunities: opps, lastDoc: null };
    }

    const ref = collection(this.firestore, 'govcon_opportunities');
    let q = query(
      ref,
      where('status', '==', filters.status || 'active'),
      orderBy('responseDeadline', 'asc'),
      limit(pageLimit)
    );

    if (filters.naicsCode) {
      q = query(q, where('naicsCodes', 'array-contains', filters.naicsCode));
    }
    if (filters.setAside && filters.setAside !== 'None') {
      q = query(q, where('setAside', '==', filters.setAside));
    }
    if (lastDoc) {
      q = query(q, startAfter(lastDoc));
    }

    const snap = await getDocs(q);
    return {
      opportunities: snap.docs.map((d) => ({ ...d.data(), id: d.id }) as GovConOpportunity),
      lastDoc: snap.docs.length > 0 ? snap.docs[snap.docs.length - 1] : null,
    };
  }

  getOpportunityById(id: string): Observable<GovConOpportunity | undefined> {
    if (environment.samGov.useMockData) {
      const opp = this.mockData.getGovConOpportunities().find(o => o.id === id);
      return new Observable(sub => { sub.next(opp); sub.complete(); });
    }
    const ref = doc(this.firestore, `govcon_opportunities/${id}`);
    return docData(ref, { idField: 'id' }) as Observable<GovConOpportunity | undefined>;
  }

  // ─── Bids ────────────────────────────────────────────────────────────────────

  async getUserBids(userId: string): Promise<GovConBid[]> {
    if (environment.samGov.useMockData) {
      return this.mockData.getGovConBids();
    }
    const ref = collection(this.firestore, 'govcon_bids');
    const q = query(ref, where('userId', '==', userId), orderBy('createdAt', 'desc'));
    const snap = await getDocs(q);
    return snap.docs.map((d) => ({ ...d.data(), id: d.id }) as GovConBid);
  }

  async getBidsByStatus(userId: string, status: BidStatus): Promise<GovConBid[]> {
    if (environment.samGov.useMockData) {
      return this.mockData.getGovConBids().filter(b => b.status === status);
    }
    const ref = collection(this.firestore, 'govcon_bids');
    const q = query(
      ref,
      where('userId', '==', userId),
      where('status', '==', status),
      orderBy('createdAt', 'desc')
    );
    const snap = await getDocs(q);
    return snap.docs.map((d) => ({ ...d.data(), id: d.id }) as GovConBid);
  }

  async createBid(
    bid: Omit<GovConBid, 'id' | 'createdAt' | 'updatedAt'>
  ): Promise<string> {
    const ref = collection(this.firestore, 'govcon_bids');
    const docRef = await addDoc(ref, {
      ...bid,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    return docRef.id;
  }

  async updateBid(id: string, updates: Partial<GovConBid>): Promise<void> {
    const ref = doc(this.firestore, `govcon_bids/${id}`);
    await updateDoc(ref, { ...updates, updatedAt: serverTimestamp() });
  }

  async deleteBid(id: string): Promise<void> {
    const ref = doc(this.firestore, `govcon_bids/${id}`);
    await deleteDoc(ref);
  }

  // ─── GovCon Profile ──────────────────────────────────────────────────────────

  getGovConProfile(userId: string): Observable<GovConProfile | undefined> {
    if (environment.samGov.useMockData) {
      const profile = this.mockData.getGovConProfile();
      return new Observable(sub => { sub.next(profile); sub.complete(); });
    }
    const ref = doc(this.firestore, `govcon_profiles/${userId}`);
    return docData(ref) as Observable<GovConProfile | undefined>;
  }

  async saveGovConProfile(profile: GovConProfile): Promise<void> {
    const ref = doc(this.firestore, `govcon_profiles/${profile.userId}`);
    await setDoc(ref, { ...profile, updatedAt: serverTimestamp() }, { merge: true });
  }

  // ─── Saved Searches ──────────────────────────────────────────────────────────

  getSavedSearches(userId: string): Observable<GovConSavedSearch[]> {
    const ref = collection(this.firestore, 'govcon_saved_searches');
    const q = query(ref, where('userId', '==', userId), orderBy('createdAt', 'desc'));
    return collectionData(q, { idField: 'id' }) as Observable<GovConSavedSearch[]>;
  }

  async createSavedSearch(
    search: Omit<GovConSavedSearch, 'id' | 'createdAt'>
  ): Promise<string> {
    const ref = collection(this.firestore, 'govcon_saved_searches');
    const docRef = await addDoc(ref, { ...search, createdAt: serverTimestamp() });
    return docRef.id;
  }

  async deleteSavedSearch(id: string): Promise<void> {
    const ref = doc(this.firestore, `govcon_saved_searches/${id}`);
    await deleteDoc(ref);
  }
}
