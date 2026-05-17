import { Injectable, signal } from '@angular/core';

/**
 * Tracks online/offline state. Use the `online` signal in components, or
 * subscribe to `change()` for one-shot events.
 */
@Injectable({ providedIn: 'root' })
export class NetworkService {
  readonly online = signal<boolean>(
    typeof navigator !== 'undefined' ? navigator.onLine : true
  );

  constructor() {
    if (typeof window === 'undefined') return;
    window.addEventListener('online', () => this.online.set(true));
    window.addEventListener('offline', () => this.online.set(false));
  }

  isOnline(): boolean {
    return this.online();
  }
}
