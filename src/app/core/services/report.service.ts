import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  addDoc,
  setDoc,
  deleteDoc,
  getDoc,
  query,
  where,
  orderBy,
  collectionData,
  serverTimestamp,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { Report, ReportReason, ReportTargetType, Block } from '../../models';

@Injectable({ providedIn: 'root' })
export class ReportService {
  private firestore = inject(Firestore);

  // ─── Reports ─────────────────────────────────────────────────────────────────

  async submitReport(
    reporterId: string,
    target: { type: ReportTargetType; id: string },
    reason: ReportReason,
    details?: string
  ): Promise<string> {
    const ref = collection(this.firestore, 'reports');
    const docRef = await addDoc(ref, {
      reporterId,
      targetType: target.type,
      targetId: target.id,
      reason,
      details: details ?? '',
      status: 'open',
      createdAt: serverTimestamp(),
    });
    return docRef.id;
  }

  myReports(reporterId: string): Observable<Report[]> {
    const ref = collection(this.firestore, 'reports');
    const q = query(
      ref,
      where('reporterId', '==', reporterId),
      orderBy('createdAt', 'desc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<Report[]>;
  }

  // ─── Blocks ─────────────────────────────────────────────────────────────────

  async block(blockerId: string, blockedId: string): Promise<void> {
    const blockId = `${blockerId}_${blockedId}`;
    const ref = doc(this.firestore, `blocks/${blockId}`);
    await setDoc(ref, {
      id: blockId,
      blockerId,
      blockedId,
      createdAt: serverTimestamp(),
    } as Block);
  }

  async unblock(blockerId: string, blockedId: string): Promise<void> {
    const blockId = `${blockerId}_${blockedId}`;
    const ref = doc(this.firestore, `blocks/${blockId}`);
    await deleteDoc(ref);
  }

  async isBlocked(blockerId: string, blockedId: string): Promise<boolean> {
    const ref = doc(this.firestore, `blocks/${blockerId}_${blockedId}`);
    const snap = await getDoc(ref);
    return snap.exists();
  }

  myBlocks(blockerId: string): Observable<Block[]> {
    const ref = collection(this.firestore, 'blocks');
    const q = query(ref, where('blockerId', '==', blockerId));
    return collectionData(q, { idField: 'id' }) as Observable<Block[]>;
  }
}
