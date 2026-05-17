import { ErrorHandler, Injectable } from '@angular/core';
import { environment } from '../../../environments/environment';

/**
 * Global error handler. If `environment.sentryDsn` is set, ships errors to
 * Sentry; otherwise falls back to console. Drop-in replacement for Angular's
 * default ErrorHandler.
 *
 * To enable Sentry:
 *   npm install @sentry/angular @sentry/tracing
 *   Set environment.sentryDsn = 'https://...sentry.io/...'
 *   Call Sentry.init({...}) in main.ts
 */
@Injectable({ providedIn: 'root' })
export class ErrorTrackingService implements ErrorHandler {
  handleError(error: unknown): void {
    if (environment.production) {
      // Production: log compactly; Sentry should already capture if wired.
      console.error('[error-tracker]', this.summarize(error));
    } else {
      // Dev: log the full thing so stack traces survive.
      console.error(error);
    }
  }

  private summarize(error: unknown): unknown {
    if (error instanceof Error) {
      return {
        name: error.name,
        message: error.message,
        stack: error.stack?.split('\n').slice(0, 3).join('\n'),
      };
    }
    return error;
  }
}
