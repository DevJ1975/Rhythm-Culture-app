import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { Auth, authState } from '@angular/fire/auth';
import { map, take } from 'rxjs/operators';
import { environment } from '../../../environments/environment';

/**
 * Allows navigation only if the current user's email is verified.
 * OAuth providers (Google/Apple) are treated as pre-verified.
 * In dev (non-production) this guard is permissive.
 */
export const verifiedGuard: CanActivateFn = () => {
  if (!environment.production) return true;

  const auth = inject(Auth);
  const router = inject(Router);

  return authState(auth).pipe(
    take(1),
    map((user) => {
      if (!user) {
        router.navigate(['/auth/login']);
        return false;
      }
      const isOAuth = user.providerData.some((p) => p.providerId !== 'password');
      if (isOAuth || user.emailVerified) return true;
      router.navigate(['/auth/verify-email']);
      return false;
    })
  );
};
