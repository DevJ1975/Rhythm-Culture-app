import { Injectable, inject } from '@angular/core';
import { Analytics, logEvent, setUserId, setUserProperties } from '@angular/fire/analytics';

/**
 * Thin wrapper around Firebase Analytics with strongly-named app events.
 *
 * Use these for funnel and retention tracking. Avoid logging PII —
 * Firebase Analytics rejects events containing user-identifiable strings.
 */
@Injectable({ providedIn: 'root' })
export class AnalyticsService {
  private analytics = inject(Analytics, { optional: true });

  identify(uid: string, traits?: { specialties?: string[]; isPro?: boolean }): void {
    if (!this.analytics) return;
    setUserId(this.analytics, uid);
    if (traits) {
      setUserProperties(this.analytics, traits as Record<string, unknown>);
    }
  }

  trackSignup(method: 'email' | 'google' | 'apple'): void {
    this.event('sign_up', { method });
  }

  trackLogin(method: 'email' | 'google' | 'apple'): void {
    this.event('login', { method });
  }

  trackPostCreated(type: string, tags: string[]): void {
    this.event('post_created', { post_type: type, tag_count: tags.length });
  }

  trackPostLiked(postId: string): void {
    this.event('post_liked', { item_id: postId });
  }

  trackPostShared(postId: string, channel: 'native' | 'copy'): void {
    this.event('share', { method: channel, content_id: postId, content_type: 'post' });
  }

  trackFollow(targetUid: string): void {
    this.event('follow_user', { item_id: targetUid });
  }

  trackPurchase(
    kind: 'event' | 'course' | 'pro_subscription',
    itemId: string | undefined,
    amount: number,
    currency: string
  ): void {
    this.event('purchase', {
      transaction_kind: kind,
      item_id: itemId,
      value: amount,
      currency,
    });
  }

  trackSearch(term: string, resultCount: number): void {
    this.event('search', { search_term: term, result_count: resultCount });
  }

  event(name: string, params: Record<string, unknown> = {}): void {
    if (!this.analytics) return;
    try {
      logEvent(this.analytics, name as any, params);
    } catch {
      // best-effort — analytics failures shouldn't break flows
    }
  }
}
