import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  collectionData,
  docData,
  serverTimestamp,
  increment,
  DocumentSnapshot,
  QueryDocumentSnapshot,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { UserProfile, FollowRelation } from '../../models';

@Injectable({
  providedIn: 'root',
})
export class UserService {
  private firestore = inject(Firestore);

  // ─── Profile ─────────────────────────────────────────────────────────────────

  getUserProfile(uid: string): Observable<UserProfile | undefined> {
    const ref = doc(this.firestore, `users/${uid}`);
    return docData(ref, { idField: 'uid' }) as Observable<UserProfile | undefined>;
  }

  async getUserProfileOnce(uid: string): Promise<UserProfile | null> {
    const ref = doc(this.firestore, `users/${uid}`);
    const snap = await getDoc(ref);
    return snap.exists() ? (snap.data() as UserProfile) : null;
  }

  async updateProfile(uid: string, updates: Partial<UserProfile>): Promise<void> {
    const ref = doc(this.firestore, `users/${uid}`);
    await updateDoc(ref, {
      ...updates,
      updatedAt: serverTimestamp(),
    });
  }

  // ─── Search ───────────────────────────────────────────────────────────────────

  async searchUsers(
    searchTerm: string,
    pageLimit = 20
  ): Promise<UserProfile[]> {
    const ref = collection(this.firestore, 'users');
    const q = query(
      ref,
      where('displayName', '>=', searchTerm),
      where('displayName', '<=', searchTerm + '\uf8ff'),
      limit(pageLimit)
    );
    const snap = await getDocs(q);
    return snap.docs.map((d) => d.data() as UserProfile);
  }

  async getUsersBySpecialty(
    specialty: string,
    pageLimit = 20,
    lastDoc?: QueryDocumentSnapshot
  ): Promise<{ users: UserProfile[]; lastDoc: QueryDocumentSnapshot | null }> {
    const ref = collection(this.firestore, 'users');
    let q = query(
      ref,
      where('specialties', 'array-contains', specialty),
      where('isPublic', '==', true),
      orderBy('followersCount', 'desc'),
      limit(pageLimit)
    );
    if (lastDoc) {
      q = query(q, startAfter(lastDoc));
    }
    const snap = await getDocs(q);
    return {
      users: snap.docs.map((d) => d.data() as UserProfile),
      lastDoc: snap.docs.length > 0 ? snap.docs[snap.docs.length - 1] : null,
    };
  }

  // ─── Follow / Unfollow ────────────────────────────────────────────────────────

  async followUser(followerId: string, followingId: string): Promise<void> {
    const followId = `${followerId}_${followingId}`;
    const followRef = doc(this.firestore, `follows/${followId}`);
    const followerRef = doc(this.firestore, `users/${followerId}`);
    const followingRef = doc(this.firestore, `users/${followingId}`);

    const follow: FollowRelation = {
      id: followId,
      followerId,
      followingId,
      createdAt: serverTimestamp() as any,
    };

    await setDoc(followRef, follow);
    await updateDoc(followerRef, { followingCount: increment(1) });
    await updateDoc(followingRef, { followersCount: increment(1) });
  }

  async unfollowUser(followerId: string, followingId: string): Promise<void> {
    const followId = `${followerId}_${followingId}`;
    const followRef = doc(this.firestore, `follows/${followId}`);
    const followerRef = doc(this.firestore, `users/${followerId}`);
    const followingRef = doc(this.firestore, `users/${followingId}`);

    const { deleteDoc } = await import('@angular/fire/firestore');
    await deleteDoc(followRef);
    await updateDoc(followerRef, { followingCount: increment(-1) });
    await updateDoc(followingRef, { followersCount: increment(-1) });
  }

  async isFollowing(followerId: string, followingId: string): Promise<boolean> {
    const followId = `${followerId}_${followingId}`;
    const followRef = doc(this.firestore, `follows/${followId}`);
    const snap = await getDoc(followRef);
    return snap.exists();
  }

  getFollowers(userId: string): Observable<FollowRelation[]> {
    const ref = collection(this.firestore, 'follows');
    const q = query(ref, where('followingId', '==', userId));
    return collectionData(q, { idField: 'id' }) as Observable<FollowRelation[]>;
  }

  getFollowing(userId: string): Observable<FollowRelation[]> {
    const ref = collection(this.firestore, 'follows');
    const q = query(ref, where('followerId', '==', userId));
    return collectionData(q, { idField: 'id' }) as Observable<FollowRelation[]>;
  }
}
