import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  query,
  where,
  orderBy,
  limit,
  getDocs,
} from '@angular/fire/firestore';
import { Post, UserProfile } from '../../models';
import { UserService } from './user.service';
import { PostService } from './post.service';

/**
 * Builds a "For You" feed by blending:
 * - Posts from users the current user follows
 * - Trending posts that match the user's specialties
 * - Recent posts with high engagement
 */
@Injectable({ providedIn: 'root' })
export class RecommendationService {
  private firestore = inject(Firestore);
  private userService = inject(UserService);
  private postService = inject(PostService);

  async forYouFeed(
    user: UserProfile,
    pageLimit = 30
  ): Promise<Post[]> {
    const followsSnap = await getDocs(
      query(
        collection(this.firestore, 'follows'),
        where('followerId', '==', user.uid),
        limit(50)
      )
    );
    const followedIds = followsSnap.docs
      .map((d) => d.data()['followingId'] as string)
      .filter(Boolean);

    const tasks: Promise<Post[]>[] = [];

    // 1. Posts from followed users (split into batches of 10 — Firestore 'in' limit)
    for (let i = 0; i < followedIds.length; i += 10) {
      const batch = followedIds.slice(i, i + 10);
      if (batch.length === 0) continue;
      tasks.push(
        getDocs(
          query(
            collection(this.firestore, 'posts'),
            where('authorId', 'in', batch),
            where('isPublic', '==', true),
            orderBy('createdAt', 'desc'),
            limit(20)
          )
        ).then((s) => s.docs.map((d) => ({ ...d.data(), id: d.id }) as Post))
      );
    }

    // 2. Trending overall
    tasks.push(this.postService.getTrendingPosts(20));

    // 3. Specialty-matched posts via tags
    const specialties = (user.specialties || []).map((s) => s.toLowerCase());
    for (const specialty of specialties.slice(0, 3)) {
      tasks.push(
        getDocs(
          query(
            collection(this.firestore, 'posts'),
            where('tags', 'array-contains', specialty),
            where('isPublic', '==', true),
            orderBy('createdAt', 'desc'),
            limit(10)
          )
        ).then((s) => s.docs.map((d) => ({ ...d.data(), id: d.id }) as Post))
      );
    }

    const batches = await Promise.all(tasks);
    const seen = new Set<string>();
    const merged: Post[] = [];
    for (const batch of batches) {
      for (const post of batch) {
        if (seen.has(post.id) || post.authorId === user.uid) continue;
        seen.add(post.id);
        merged.push(post);
      }
    }

    // Re-rank by a simple decayed engagement score
    return merged
      .map((post) => ({
        post,
        score: this.scorePost(post, followedIds),
      }))
      .sort((a, b) => b.score - a.score)
      .slice(0, pageLimit)
      .map((s) => s.post);
  }

  private scorePost(post: Post, followedIds: string[]): number {
    const createdAt =
      (post.createdAt as any)?.toMillis?.() ??
      (post.createdAt as any)?.seconds * 1000 ??
      Date.now();
    const hours = Math.max(1, (Date.now() - createdAt) / (60 * 60 * 1000));
    const engagement =
      (post.likesCount || 0) +
      2 * (post.commentsCount || 0) +
      3 * (post.sharesCount || 0);
    const fromFollowed = followedIds.includes(post.authorId) ? 25 : 0;
    return engagement / Math.pow(hours, 1.2) + fromFollowed;
  }
}
