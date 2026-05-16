import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  addDoc,
  deleteDoc,
  setDoc,
  query,
  where,
  orderBy,
  collectionData,
  serverTimestamp,
  Timestamp,
  getDocs,
  increment,
  updateDoc,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { Story } from '../../models';

@Injectable({ providedIn: 'root' })
export class StoryService {
  private firestore = inject(Firestore);

  /** Returns active (non-expired) stories ordered by recency. */
  active(): Observable<Story[]> {
    const ref = collection(this.firestore, 'stories');
    const q = query(
      ref,
      where('expiresAt', '>', Timestamp.now()),
      orderBy('expiresAt', 'desc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<Story[]>;
  }

  async create(
    authorId: string,
    payload: {
      mediaUrl: string;
      mediaType: 'image' | 'video';
      storagePath: string;
      caption?: string;
      duration?: number;
      thumbnailUrl?: string;
    }
  ): Promise<string> {
    const ref = collection(this.firestore, 'stories');
    const expiresAt = Timestamp.fromMillis(Date.now() + 24 * 60 * 60 * 1000);
    const docRef = await addDoc(ref, {
      authorId,
      ...payload,
      viewersCount: 0,
      expiresAt,
      createdAt: serverTimestamp(),
    });
    return docRef.id;
  }

  async recordView(storyId: string, viewerId: string): Promise<void> {
    const viewRef = doc(
      this.firestore,
      `stories/${storyId}/views/${viewerId}`
    );
    await setDoc(viewRef, { viewerId, viewedAt: serverTimestamp() }, { merge: true });
    await updateDoc(doc(this.firestore, `stories/${storyId}`), {
      viewersCount: increment(1),
    });
  }

  async delete(storyId: string): Promise<void> {
    const viewsSnap = await getDocs(
      collection(this.firestore, `stories/${storyId}/views`)
    );
    await Promise.all(viewsSnap.docs.map((d) => deleteDoc(d.ref)));
    await deleteDoc(doc(this.firestore, `stories/${storyId}`));
  }
}
