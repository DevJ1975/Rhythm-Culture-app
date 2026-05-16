import { Injectable, inject } from '@angular/core';
import { Functions, httpsCallable } from '@angular/fire/functions';

export type CheckoutKind = 'event' | 'course' | 'pro_subscription';

@Injectable({ providedIn: 'root' })
export class PaymentService {
  private functions = inject(Functions);

  async checkout(kind: CheckoutKind, itemId?: string): Promise<void> {
    const fn = httpsCallable<{ kind: CheckoutKind; itemId?: string }, { url: string }>(
      this.functions,
      'createCheckoutSession'
    );
    const { data } = await fn({ kind, itemId });
    if (data?.url) {
      window.location.href = data.url;
    }
  }

  async startConnectOnboarding(): Promise<void> {
    const fn = httpsCallable<unknown, { url: string }>(
      this.functions,
      'createConnectOnboarding'
    );
    const { data } = await fn({});
    if (data?.url) {
      window.location.href = data.url;
    }
  }
}
