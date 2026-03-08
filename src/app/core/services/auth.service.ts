import { Injectable, inject } from '@angular/core';
import { Router } from '@angular/router';
import {
  Auth,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
  GoogleAuthProvider,
  signInWithPopup,
  signInWithRedirect,
  getRedirectResult,
  sendPasswordResetEmail,
  updateProfile,
  User,
  user,
  authState,
  OAuthProvider,
} from '@angular/fire/auth';
import {
  Firestore,
  doc,
  setDoc,
  getDoc,
  serverTimestamp,
} from '@angular/fire/firestore';
import { Observable, from, of } from 'rxjs';
import { switchMap, map } from 'rxjs/operators';
import { UserProfile } from '../../models';
import { Capacitor } from '@capacitor/core';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private auth = inject(Auth);
  private firestore = inject(Firestore);
  private router = inject(Router);

  // Observable of the raw Firebase user
  readonly firebaseUser$: Observable<User | null> = authState(this.auth);

  // Observable of the full Firestore user profile
  readonly currentUser$: Observable<UserProfile | null> = this.firebaseUser$.pipe(
    switchMap((firebaseUser) => {
      if (!firebaseUser) return of(null);
      const userRef = doc(this.firestore, `users/${firebaseUser.uid}`);
      return from(getDoc(userRef)).pipe(
        map((snap) => (snap.exists() ? (snap.data() as UserProfile) : null))
      );
    })
  );

  get currentUser(): User | null {
    return this.auth.currentUser;
  }

  // ─── Email & Password ────────────────────────────────────────────────────────

  async registerWithEmail(
    email: string,
    password: string,
    displayName: string
  ): Promise<UserProfile> {
    const credential = await createUserWithEmailAndPassword(
      this.auth,
      email,
      password
    );
    await updateProfile(credential.user, { displayName });
    return this.createUserProfile(credential.user, { displayName });
  }

  async loginWithEmail(email: string, password: string): Promise<void> {
    await signInWithEmailAndPassword(this.auth, email, password);
  }

  // ─── Google Auth ─────────────────────────────────────────────────────────────

  async loginWithGoogle(): Promise<void> {
    const provider = new GoogleAuthProvider();
    provider.addScope('email');
    provider.addScope('profile');

    if (Capacitor.isNativePlatform()) {
      await signInWithRedirect(this.auth, provider);
    } else {
      const credential = await signInWithPopup(this.auth, provider);
      await this.createUserProfileIfNotExists(credential.user);
    }
  }

  async handleGoogleRedirectResult(): Promise<void> {
    const result = await getRedirectResult(this.auth);
    if (result?.user) {
      await this.createUserProfileIfNotExists(result.user);
    }
  }

  // ─── Apple Auth ──────────────────────────────────────────────────────────────

  async loginWithApple(): Promise<void> {
    const provider = new OAuthProvider('apple.com');
    provider.addScope('email');
    provider.addScope('name');

    if (Capacitor.isNativePlatform()) {
      await signInWithRedirect(this.auth, provider);
    } else {
      const credential = await signInWithPopup(this.auth, provider);
      await this.createUserProfileIfNotExists(credential.user);
    }
  }

  // ─── Password Reset ───────────────────────────────────────────────────────────

  async sendPasswordReset(email: string): Promise<void> {
    await sendPasswordResetEmail(this.auth, email);
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────────

  async signOut(): Promise<void> {
    await signOut(this.auth);
    await this.router.navigate(['/auth/login']);
  }

  // ─── Profile Helpers ──────────────────────────────────────────────────────────

  private async createUserProfileIfNotExists(firebaseUser: User): Promise<void> {
    const userRef = doc(this.firestore, `users/${firebaseUser.uid}`);
    const snap = await getDoc(userRef);
    if (!snap.exists()) {
      await this.createUserProfile(firebaseUser);
    }
  }

  private async createUserProfile(
    firebaseUser: User,
    extraData: Partial<UserProfile> = {}
  ): Promise<UserProfile> {
    const userRef = doc(this.firestore, `users/${firebaseUser.uid}`);
    const now = serverTimestamp();

    const profile: Omit<UserProfile, 'createdAt' | 'updatedAt'> = {
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: extraData.displayName ?? firebaseUser.displayName ?? '',
      artistName: extraData.displayName ?? firebaseUser.displayName ?? '',
      photoURL: firebaseUser.photoURL ?? undefined,
      specialties: [],
      followersCount: 0,
      followingCount: 0,
      postsCount: 0,
      isVerified: false,
      isPro: false,
      isPublic: true,
    };

    const fullProfile = {
      ...profile,
      createdAt: now,
      updatedAt: now,
      lastActiveAt: now,
    };

    await setDoc(userRef, fullProfile);
    return fullProfile as unknown as UserProfile;
  }

  isAuthenticated(): boolean {
    return !!this.auth.currentUser;
  }
}
