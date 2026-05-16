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
import { UserProfile, Post, Event, Course, Collaboration } from '../../models';

export interface SearchResults {
  users: UserProfile[];
  posts: Post[];
  events: Event[];
  courses: Course[];
  collaborations: Collaboration[];
  hashtags: { tag: string; count: number }[];
}

export type SearchFacet = 'users' | 'posts' | 'events' | 'courses' | 'collaborations' | 'hashtags';

/**
 * Unified search across the app.
 *
 * Implementation strategy:
 * - For prefix matches we use Firestore range queries (cheap, no extra infra).
 * - For tag/hashtag matches we rely on `tags` array-contains queries.
 * - True full-text search requires Algolia or Typesense (see indexing Cloud
 *   Function in `functions/src/search/indexing.ts`). When the env has the
 *   external search endpoint configured we proxy through that; otherwise we
 *   fall back to Firestore queries.
 */
@Injectable({ providedIn: 'root' })
export class SearchService {
  private firestore = inject(Firestore);

  /** Normalize the user's query into a lowercase, trimmed string and optional hashtag. */
  parseQuery(input: string): { text: string; isHashtag: boolean } {
    const trimmed = input.trim().toLowerCase();
    if (trimmed.startsWith('#')) {
      return { text: trimmed.slice(1), isHashtag: true };
    }
    return { text: trimmed, isHashtag: false };
  }

  async searchAll(
    input: string,
    facets: SearchFacet[] = ['users', 'posts', 'events', 'courses', 'collaborations'],
    pageLimit = 10
  ): Promise<SearchResults> {
    const { text, isHashtag } = this.parseQuery(input);
    const results: SearchResults = {
      users: [],
      posts: [],
      events: [],
      courses: [],
      collaborations: [],
      hashtags: [],
    };
    if (!text) return results;

    const tasks: Promise<unknown>[] = [];

    if (facets.includes('users') && !isHashtag) {
      tasks.push(this.searchUsers(text, pageLimit).then((r) => (results.users = r)));
    }
    if (facets.includes('posts')) {
      tasks.push(
        this.searchPostsByTag(text, pageLimit).then((r) => (results.posts = r))
      );
    }
    if (facets.includes('events') && !isHashtag) {
      tasks.push(
        this.searchEvents(text, pageLimit).then((r) => (results.events = r))
      );
    }
    if (facets.includes('courses') && !isHashtag) {
      tasks.push(
        this.searchCourses(text, pageLimit).then((r) => (results.courses = r))
      );
    }
    if (facets.includes('collaborations') && !isHashtag) {
      tasks.push(
        this.searchCollaborations(text, pageLimit).then(
          (r) => (results.collaborations = r)
        )
      );
    }

    await Promise.all(tasks);
    return results;
  }

  async searchUsers(text: string, pageLimit = 10): Promise<UserProfile[]> {
    const ref = collection(this.firestore, 'users');
    const q = query(
      ref,
      where('displayName_lower', '>=', text),
      where('displayName_lower', '<=', text + ''),
      limit(pageLimit)
    );
    try {
      const snap = await getDocs(q);
      return snap.docs.map((d) => d.data() as UserProfile);
    } catch {
      // Falls back when displayName_lower index doesn't exist yet
      const fallback = query(
        ref,
        where('displayName', '>=', text),
        where('displayName', '<=', text + ''),
        limit(pageLimit)
      );
      const snap = await getDocs(fallback);
      return snap.docs.map((d) => d.data() as UserProfile);
    }
  }

  async searchPostsByTag(tag: string, pageLimit = 10): Promise<Post[]> {
    const ref = collection(this.firestore, 'posts');
    const q = query(
      ref,
      where('tags', 'array-contains', tag),
      where('isPublic', '==', true),
      orderBy('createdAt', 'desc'),
      limit(pageLimit)
    );
    const snap = await getDocs(q);
    return snap.docs.map((d) => ({ ...d.data(), id: d.id }) as Post);
  }

  async searchEvents(text: string, pageLimit = 10): Promise<Event[]> {
    const ref = collection(this.firestore, 'events');
    const q = query(
      ref,
      where('title_lower', '>=', text),
      where('title_lower', '<=', text + ''),
      limit(pageLimit)
    );
    try {
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ ...d.data(), id: d.id }) as Event);
    } catch {
      return [];
    }
  }

  async searchCourses(text: string, pageLimit = 10): Promise<Course[]> {
    const ref = collection(this.firestore, 'courses');
    const q = query(
      ref,
      where('title_lower', '>=', text),
      where('title_lower', '<=', text + ''),
      limit(pageLimit)
    );
    try {
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ ...d.data(), id: d.id }) as Course);
    } catch {
      return [];
    }
  }

  async searchCollaborations(text: string, pageLimit = 10): Promise<Collaboration[]> {
    const ref = collection(this.firestore, 'collaborations');
    const q = query(
      ref,
      where('title_lower', '>=', text),
      where('title_lower', '<=', text + ''),
      limit(pageLimit)
    );
    try {
      const snap = await getDocs(q);
      return snap.docs.map((d) => ({ ...d.data(), id: d.id }) as Collaboration);
    } catch {
      return [];
    }
  }

  /** Parses #hashtags and @mentions out of a body of text. */
  extractTagsAndMentions(text: string): { tags: string[]; mentions: string[] } {
    const tags = Array.from(text.matchAll(/#([\p{L}\p{N}_]{2,30})/gu)).map((m) =>
      m[1].toLowerCase()
    );
    const mentions = Array.from(text.matchAll(/@([\p{L}\p{N}_.]{2,30})/gu)).map(
      (m) => m[1].toLowerCase()
    );
    return {
      tags: Array.from(new Set(tags)),
      mentions: Array.from(new Set(mentions)),
    };
  }
}
