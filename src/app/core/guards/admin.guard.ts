import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { Auth } from '@angular/fire/auth';
import { environment } from '../../../environments/environment';

/**
 * Requires the user's Firebase ID token to carry an `admin: true` custom claim.
 * Claims are granted by the `grantAdmin` callable Cloud Function.
 */
export const adminGuard: CanActivateFn = async () => {
  if (!environment.production) return true;

  const auth = inject(Auth);
  const router = inject(Router);
  const user = auth.currentUser;
  if (!user) {
    router.navigate(['/auth/login']);
    return false;
  }
  const token = await user.getIdTokenResult();
  if (token.claims['admin'] === true) return true;
  router.navigate(['/tabs/feed']);
  return false;
};
