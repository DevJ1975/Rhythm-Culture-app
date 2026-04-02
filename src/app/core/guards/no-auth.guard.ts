import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { Auth, authState } from '@angular/fire/auth';
import { map, take } from 'rxjs/operators';
import { environment } from '../../../environments/environment';

export const noAuthGuard: CanActivateFn = () => {
  if (!environment.production) {
    inject(Router).navigate(['/tabs/feed']);
    return false;
  }

  const auth = inject(Auth);
  const router = inject(Router);

  return authState(auth).pipe(
    take(1),
    map((user) => {
      if (!user) return true;
      router.navigate(['/tabs/feed']);
      return false;
    })
  );
};
