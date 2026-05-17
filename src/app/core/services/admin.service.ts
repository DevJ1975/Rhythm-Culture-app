import { Injectable, inject } from '@angular/core';
import { Functions, httpsCallable } from '@angular/fire/functions';
import { Auth } from '@angular/fire/auth';

@Injectable({ providedIn: 'root' })
export class AdminService {
  private functions = inject(Functions);
  private auth = inject(Auth);

  /** True when the current user has an `admin: true` custom claim. */
  async isAdmin(): Promise<boolean> {
    if (!this.auth.currentUser) return false;
    const token = await this.auth.currentUser.getIdTokenResult();
    return token.claims['admin'] === true;
  }

  async bootstrapAdmin(): Promise<void> {
    const fn = httpsCallable(this.functions, 'bootstrapAdmin');
    await fn({});
  }

  async grantAdmin(uid: string): Promise<void> {
    const fn = httpsCallable(this.functions, 'grantAdmin');
    await fn({ uid });
  }

  async revokeAdmin(uid: string): Promise<void> {
    const fn = httpsCallable(this.functions, 'revokeAdmin');
    await fn({ uid });
  }

  async setUserVerified(uid: string, verified: boolean): Promise<void> {
    const fn = httpsCallable(this.functions, 'setUserVerified');
    await fn({ uid, verified });
  }
}
