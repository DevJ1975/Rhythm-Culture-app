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
  setDoc,
  QueryDocumentSnapshot,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { Post, Comment, PostLike } from '../../models';

@Injectable({
  providedIn: 'root',
})
export class PostService {
  private firestore = inject(Firestore);

  // ─── Feed ─────────────────────────────────────────────────────────────────────

  async getFeedPosts(
    pageLimit = 10,
    lastDoc?: QueryDocumentSnapshot
  ): Promise<{ posts: Post[]; lastDoc: QueryDocumentSnapshot | null }> {
    const ref = collection(this.firestore, 'posts');
    let q = query(
      ref,
      where('isPublic', '==', true),
      orderBy('createdAt', 'desc'),
      limit(pageLimit)
    );
    if (lastDoc) {
      q = query(q, startAfter(lastDoc));
    }
    const snap = await getDocs(q);
    return {
      posts: snap.docs.map((d) => ({ ...d.data(), id: d.id }) as Post),
      lastDoc: snap.docs.length > 0 ? snap.docs[snap.docs.length - 1] : null,
    };
  }

  async getUserPosts(
    userId: string,
    pageLimit = 12,
    lastDoc?: QueryDocumentSnapshot
  ): Promise<{ posts: Post[]; lastDoc: QueryDocumentSnapshot | null }> {
    const ref = collection(this.firestore, 'posts');
    let q = query(
      ref,
      where('authorId', '==', userId),
      orderBy('createdAt', 'desc'),
      limit(pageLimit)
    );
    if (lastDoc) {
      q = query(q, startAfter(lastDoc));
    }
    const snap = await getDocs(q);
    return {
      posts: snap.docs.map((d) => ({ ...d.data(), id: d.id }) as Post),
      lastDoc: snap.docs.length > 0 ? snap.docs[snap.docs.length - 1] : null,
    };
  }

  getPostById(postId: string): Observable<Post | undefined> {
    const ref = doc(this.firestore, `posts/${postId}`);
    return docData(ref, { idField: 'id' }) as Observable<Post | undefined>;
  }

  // ─── Create / Delete ──────────────────────────────────────────────────────────

  async createPost(post: Omit<Post, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    const ref = collection(this.firestore, 'posts');
    const docRef = await addDoc(ref, {
      ...post,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });

    // Increment user post count
    const userRef = doc(this.firestore, `users/${post.authorId}`);
    await updateDoc(userRef, { postsCount: increment(1) });

    return docRef.id;
  }

  async deletePost(postId: string, authorId: string): Promise<void> {
    const postRef = doc(this.firestore, `posts/${postId}`);
    await deleteDoc(postRef);

    const userRef = doc(this.firestore, `users/${authorId}`);
    await updateDoc(userRef, { postsCount: increment(-1) });
  }

  // ─── Likes ────────────────────────────────────────────────────────────────────

  async likePost(postId: string, userId: string): Promise<void> {
    const likeRef = doc(this.firestore, `posts/${postId}/likes/${userId}`);
    const postRef = doc(this.firestore, `posts/${postId}`);
    await setDoc(likeRef, { userId, postId, createdAt: serverTimestamp() });
    await updateDoc(postRef, { likesCount: increment(1) });
  }

  async unlikePost(postId: string, userId: string): Promise<void> {
    const likeRef = doc(this.firestore, `posts/${postId}/likes/${userId}`);
    const postRef = doc(this.firestore, `posts/${postId}`);
    await deleteDoc(likeRef);
    await updateDoc(postRef, { likesCount: increment(-1) });
  }

  async hasLiked(postId: string, userId: string): Promise<boolean> {
    const likeRef = doc(this.firestore, `posts/${postId}/likes/${userId}`);
    const snap = await getDoc(likeRef);
    return snap.exists();
  }

  // ─── Comments ─────────────────────────────────────────────────────────────────

  getComments(postId: string): Observable<Comment[]> {
    const ref = collection(this.firestore, 'comments');
    const q = query(
      ref,
      where('postId', '==', postId),
      where('parentCommentId', '==', null),
      orderBy('createdAt', 'asc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<Comment[]>;
  }

  async addComment(
    comment: Omit<Comment, 'id' | 'createdAt'>
  ): Promise<string> {
    const ref = collection(this.firestore, 'comments');
    const postRef = doc(this.firestore, `posts/${comment.postId}`);
    const docRef = await addDoc(ref, {
      ...comment,
      createdAt: serverTimestamp(),
    });
    await updateDoc(postRef, { commentsCount: increment(1) });
    return docRef.id;
  }

  async deleteComment(commentId: string, postId: string): Promise<void> {
    const commentRef = doc(this.firestore, `comments/${commentId}`);
    const postRef = doc(this.firestore, `posts/${postId}`);
    await deleteDoc(commentRef);
    await updateDoc(postRef, { commentsCount: increment(-1) });
  }
}
