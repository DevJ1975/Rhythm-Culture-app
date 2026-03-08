import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  addDoc,
  getDoc,
  getDocs,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  collectionData,
  docData,
  serverTimestamp,
  increment,
  QueryDocumentSnapshot,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { Collaboration, CollaborationApplication } from '../../models';

@Injectable({
  providedIn: 'root',
})
export class CollaborationService {
  private firestore = inject(Firestore);

  // ─── List / Filter ────────────────────────────────────────────────────────────

  async getCollaborations(
    filters: {
      skill?: string;
      location?: string;
      type?: string;
      isRemote?: boolean;
    } = {},
    pageLimit = 10,
    lastDoc?: QueryDocumentSnapshot
  ): Promise<{ collabs: Collaboration[]; lastDoc: QueryDocumentSnapshot | null }> {
    const ref = collection(this.firestore, 'collaborations');
    let q = query(
      ref,
      where('status', '==', 'open'),
      orderBy('createdAt', 'desc'),
      limit(pageLimit)
    );

    if (filters.skill) {
      q = query(q, where('skills', 'array-contains', filters.skill));
    }
    if (filters.isRemote !== undefined) {
      q = query(q, where('isRemote', '==', filters.isRemote));
    }
    if (lastDoc) {
      q = query(q, startAfter(lastDoc));
    }

    const snap = await getDocs(q);
    return {
      collabs: snap.docs.map((d) => ({ ...d.data(), id: d.id }) as Collaboration),
      lastDoc: snap.docs.length > 0 ? snap.docs[snap.docs.length - 1] : null,
    };
  }

  getCollaborationById(id: string): Observable<Collaboration | undefined> {
    const ref = doc(this.firestore, `collaborations/${id}`);
    return docData(ref, { idField: 'id' }) as Observable<Collaboration | undefined>;
  }

  getUserCollaborations(userId: string): Observable<Collaboration[]> {
    const ref = collection(this.firestore, 'collaborations');
    const q = query(
      ref,
      where('creatorId', '==', userId),
      orderBy('createdAt', 'desc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<Collaboration[]>;
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────────

  async createCollaboration(
    collab: Omit<Collaboration, 'id' | 'createdAt' | 'updatedAt' | 'currentApplicants'>
  ): Promise<string> {
    const ref = collection(this.firestore, 'collaborations');
    const docRef = await addDoc(ref, {
      ...collab,
      currentApplicants: 0,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    return docRef.id;
  }

  async updateCollaboration(
    id: string,
    updates: Partial<Collaboration>
  ): Promise<void> {
    const ref = doc(this.firestore, `collaborations/${id}`);
    await updateDoc(ref, { ...updates, updatedAt: serverTimestamp() });
  }

  async deleteCollaboration(id: string): Promise<void> {
    const ref = doc(this.firestore, `collaborations/${id}`);
    await deleteDoc(ref);
  }

  // ─── Applications ─────────────────────────────────────────────────────────────

  async applyToCollaboration(
    application: Omit<CollaborationApplication, 'id' | 'appliedAt' | 'status'>
  ): Promise<string> {
    const ref = collection(this.firestore, 'collaboration_applications');
    const collabRef = doc(
      this.firestore,
      `collaborations/${application.collaborationId}`
    );

    const docRef = await addDoc(ref, {
      ...application,
      status: 'pending',
      appliedAt: serverTimestamp(),
    });

    await updateDoc(collabRef, { currentApplicants: increment(1) });
    return docRef.id;
  }

  getApplicationsForCollaboration(
    collaborationId: string
  ): Observable<CollaborationApplication[]> {
    const ref = collection(this.firestore, 'collaboration_applications');
    const q = query(
      ref,
      where('collaborationId', '==', collaborationId),
      orderBy('appliedAt', 'desc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<CollaborationApplication[]>;
  }

  async respondToApplication(
    applicationId: string,
    status: 'accepted' | 'rejected'
  ): Promise<void> {
    const ref = doc(
      this.firestore,
      `collaboration_applications/${applicationId}`
    );
    await updateDoc(ref, { status, respondedAt: serverTimestamp() });
  }
}
