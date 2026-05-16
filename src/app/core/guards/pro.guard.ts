import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { Auth } from '@angular/fire/auth';
import {
  Firestore,
  doc,
  getDoc,
} from '@angular/fire/firestore';
import { environment } from '../../../environments/environment';

/**
 * Gates routes that require a Pro subscription. Reads `isPro` off the user's
 * Firestore profile and redirects to the upgrade page if missing.
 */
export const proGuard: CanActivateFn = async () => {
  if (!environment.production) return true;

  const auth = inject(Auth);
  const firestore = inject(Firestore);
  const router = inject(Router);
  const user = auth.currentUser;
  if (!user) {
    router.navigate(['/auth/login']);
    return false;
  }
  const snap = await getDoc(doc(firestore, `users/${user.uid}`));
  if (snap.exists() && snap.data()['isPro'] === true) return true;
  router.navigate(['/upgrade']);
  return false;
};
