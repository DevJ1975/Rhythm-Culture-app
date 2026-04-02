# Rhythm Culture — Junior Developer Guide

A practical, hands-on reference for making changes and adding features to this platform. Every example in this guide is pulled from the actual codebase — not generic tutorials.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Getting Started Locally](#2-getting-started-locally)
3. [Project Structure](#3-project-structure)
4. [Core Architecture Concepts](#4-core-architecture-concepts)
5. [Adding a New Page](#5-adding-a-new-page)
6. [Routing — Adding & Modifying Routes](#6-routing--adding--modifying-routes)
7. [Services — Reading & Writing Firestore Data](#7-services--reading--writing-firestore-data)
8. [Data Models — TypeScript Interfaces](#8-data-models--typescript-interfaces)
9. [Styling — Ionic + Tailwind CSS](#9-styling--ionic--tailwind-css)
10. [Forms — Reactive Forms Pattern](#10-forms--reactive-forms-pattern)
11. [Firebase Auth Patterns](#11-firebase-auth-patterns)
12. [File Uploads — Storage Service](#12-file-uploads--storage-service)
13. [Cloud Functions](#13-cloud-functions)
14. [Platform Detection — Web vs Native](#14-platform-detection--web-vs-native)
15. [Common Patterns Quick Reference](#15-common-patterns-quick-reference)
16. [Things That Will Trip You Up](#16-things-that-will-trip-you-up)

---

## 1. Project Overview

**Rhythm Culture** is a social platform for the global performing arts community — think Instagram meets LinkedIn for dancers, musicians, and artists.

| Layer | Technology |
|-------|-----------|
| Frontend framework | Angular 17 (Standalone Components) |
| UI components | Ionic 7 |
| Styling | Tailwind CSS 3 |
| Backend | Firebase (Auth, Firestore, Storage, Functions) |
| Mobile (later) | Capacitor 5 |
| Language | TypeScript throughout |

> **Current focus: Web first.** We are building and polishing the web experience before tackling mobile (Capacitor/iOS/Android). When in doubt, make sure it works great in a browser first.

---

## 2. Getting Started Locally

### Prerequisites
- Node.js 18+
- Firebase CLI: `npm install -g firebase-tools`

### First-time setup

```bash
# Install dependencies
npm install

# Install Cloud Functions dependencies
cd functions && npm install && cd ..

# Start the app (web)
npm start
```

The app will open at `http://localhost:8100`.

### With Firebase Emulators (recommended)

Running the emulators lets you develop without touching production data.

```bash
# Terminal 1 — start emulators
firebase emulators:start

# Terminal 2 — start the app (emulator mode is on by default in dev)
npm start
```

The environment file at `src/environments/environment.ts` has `useEmulators: true` in development. This means all Firestore, Auth, and Storage calls go to your local machine — not the real database.

### Environment Config

`src/environments/environment.ts` is where Firebase credentials live. **Never commit real production keys.** The file looks like this:

```typescript
export const environment = {
  production: false,
  firebase: {
    apiKey: 'your-api-key',
    authDomain: 'your-project.firebaseapp.com',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    messagingSenderId: '000000000',
    appId: '1:000000000:web:000000000',
  },
  useEmulators: true,
  appVersion: '1.0.0',
};
```

---

## 3. Project Structure

```
src/app/
├── core/
│   ├── services/       ← All data/business logic lives here
│   │   ├── auth.service.ts
│   │   ├── post.service.ts
│   │   ├── user.service.ts
│   │   ├── storage.service.ts
│   │   ├── event.service.ts
│   │   ├── course.service.ts
│   │   ├── messaging.service.ts
│   │   ├── collaboration.service.ts
│   │   └── notification.service.ts
│   └── guards/
│       ├── auth.guard.ts        ← Blocks unauthenticated users
│       └── no-auth.guard.ts     ← Blocks authenticated users from login
├── models/             ← TypeScript interfaces for all data
│   ├── user.model.ts
│   ├── post.model.ts
│   ├── event.model.ts
│   └── index.ts        ← Re-exports everything, import from here
├── pages/              ← One folder per screen
│   ├── auth/
│   ├── feed/
│   ├── discover/
│   ├── profile/
│   └── ...
├── shared/
│   └── components/     ← Reusable UI pieces
│       ├── post-card/
│       ├── user-avatar/
│       ├── specialty-badge/
│       └── empty-state/
├── app.config.ts       ← App bootstrap: Firebase, routing, Ionic setup
└── app.routes.ts       ← All route definitions
```

**Rule of thumb:** If it talks to Firebase, it belongs in a service. If it's a screen, it belongs in pages. If it's used in more than one page, it belongs in shared/components.

---

## 4. Core Architecture Concepts

### Standalone Components

Every component in this project is **standalone**. This means there are no NgModules — each component declares its own imports.

```typescript
@Component({
  selector: 'app-my-page',
  templateUrl: './my-page.page.html',
  standalone: true,                 // ← required
  imports: [
    CommonModule,                   // *ngIf, *ngFor, pipes
    ReactiveFormsModule,            // forms
    IonHeader, IonToolbar,          // Ionic components — each imported individually
    PostCardComponent,              // shared components — imported directly
  ],
})
export class MyPage { }
```

If you use an Ionic component in a template but forget to import it here, Angular will silently ignore it and nothing will render.

### Dependency Injection — use `inject()`

Inject services with the `inject()` function, not constructor parameters:

```typescript
// ✅ Correct — used throughout this codebase
export class FeedPage {
  private postService = inject(PostService);
  private authService = inject(AuthService);
}

// ❌ Old style — don't use
export class FeedPage {
  constructor(private postService: PostService) {}
}
```

### Ionic + Angular = Both CSS Systems

Ionic provides ready-made components (`<ion-button>`, `<ion-card>`, etc.). Tailwind provides utility classes. Both are used at the same time:

```html
<ion-button class="font-bold text-sm" style="--border-radius: 12px;">
  Follow
</ion-button>
```

Ionic component properties (like `--border-radius`) use CSS custom properties set via `style=""`. Layout and spacing use Tailwind classes.

---

## 5. Adding a New Page

Here is the exact recipe to add a new page. This is copy-pasteable.

### Step 1 — Create the folder and files

Create a folder in `src/app/pages/`. You need three files:

```
src/app/pages/my-feature/
├── my-feature.page.ts
├── my-feature.page.html
└── my-feature.page.scss   (can be empty)
```

### Step 2 — Write the component

`my-feature.page.ts`:

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton,
  IonIcon, IonButtons, IonSpinner,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { chevronBackOutline } from 'ionicons/icons';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-my-feature',
  templateUrl: './my-feature.page.html',
  styleUrls: ['./my-feature.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterModule,
    IonHeader, IonToolbar, IonTitle, IonContent,
    IonButton, IonIcon, IonButtons, IonSpinner,
  ],
})
export class MyFeaturePage implements OnInit {
  private authService = inject(AuthService);

  isLoading = true;
  items: any[] = [];

  constructor() {
    addIcons({ chevronBackOutline });
  }

  async ngOnInit(): Promise<void> {
    // Load your data here
    this.isLoading = false;
  }

  goBack(): void {
    window.history.back();
  }
}
```

### Step 3 — Write the template

`my-feature.page.html`:

```html
<ion-header>
  <ion-toolbar>
    <ion-buttons slot="start">
      <ion-button fill="clear" (click)="goBack()">
        <ion-icon name="chevron-back-outline" class="text-white"></ion-icon>
      </ion-button>
    </ion-buttons>
    <ion-title>My Feature</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content class="ion-padding">

  <!-- Loading state -->
  <div *ngIf="isLoading" class="flex justify-center items-center h-40">
    <ion-spinner name="crescent"></ion-spinner>
  </div>

  <!-- Empty state -->
  <app-empty-state
    *ngIf="!isLoading && items.length === 0"
    icon="albums-outline"
    title="Nothing here yet"
    message="Check back soon."
  ></app-empty-state>

  <!-- Content -->
  <div *ngIf="!isLoading && items.length > 0">
    <div *ngFor="let item of items; trackBy: trackById" class="mb-4">
      <!-- item content -->
    </div>
  </div>

</ion-content>
```

### Step 4 — Register the route

Open `src/app/app.routes.ts` and add your route. If it's a detail page (not a tab), add it to the standalone routes section:

```typescript
{
  path: 'my-feature/:id',
  canActivate: [authGuard],
  loadComponent: () =>
    import('./pages/my-feature/my-feature.page').then((m) => m.MyFeaturePage),
},
```

If it should be a tab, add it inside the `tabs` children array instead.

---

## 6. Routing — Adding & Modifying Routes

All routes live in `src/app/app.routes.ts`. The file is split into three zones:

```
Zone 1: /auth/**         → noAuthGuard (only unauthenticated users)
Zone 2: /tabs/**         → authGuard + tab layout (the main app)
Zone 3: standalone paths → authGuard (detail pages, no tabs)
```

### Route structure at a glance

```typescript
export const routes: Routes = [
  { path: '', redirectTo: '/tabs/feed', pathMatch: 'full' },

  // Auth (logged-out users only)
  {
    path: 'auth',
    canActivate: [noAuthGuard],
    children: [
      { path: 'login', loadComponent: () => import('./pages/auth/login/login.page').then(m => m.LoginPage) },
      { path: 'register', loadComponent: () => import('./pages/auth/register/register.page').then(m => m.RegisterPage) },
      { path: '', redirectTo: 'login', pathMatch: 'full' },
    ],
  },

  // Main app — tabs layout
  {
    path: 'tabs',
    canActivate: [authGuard],
    loadComponent: () => import('./pages/tabs/tabs.page').then(m => m.TabsPage),
    children: [
      { path: 'feed', loadComponent: () => import('./pages/feed/feed.page').then(m => m.FeedPage) },
      { path: 'profile', loadComponent: () => import('./pages/profile/profile.page').then(m => m.ProfilePage) },
      // Add new tab pages here
      { path: '', redirectTo: 'feed', pathMatch: 'full' },
    ],
  },

  // Detail pages (no tabs, auth required)
  { path: 'post/:id', canActivate: [authGuard], loadComponent: () => import('./pages/post-detail/post-detail.page').then(m => m.PostDetailPage) },
  { path: 'profile/:uid', canActivate: [authGuard], loadComponent: () => import('./pages/profile/profile.page').then(m => m.ProfilePage) },

  { path: '**', redirectTo: '/tabs/feed' },
];
```

### Navigating programmatically

```typescript
private router = inject(Router);

// Navigate to a route
await this.router.navigate(['/tabs/feed']);

// Navigate with a parameter
await this.router.navigate(['/post', postId]);

// Navigate and replace history (no back button)
await this.router.navigate(['/tabs/feed'], { replaceUrl: true });
```

### Reading route parameters

```typescript
import { ActivatedRoute } from '@angular/router';

export class PostDetailPage implements OnInit {
  private route = inject(ActivatedRoute);

  ngOnInit(): void {
    const postId = this.route.snapshot.paramMap.get('id');
  }
}
```

### Navigating in templates

```html
<!-- Declarative link -->
<ion-button routerLink="/tabs/discover">Discover</ion-button>

<!-- With a parameter -->
<div [routerLink]="['/post', post.id]">View Post</div>
```

---

## 7. Services — Reading & Writing Firestore Data

All database logic lives in `src/app/core/services/`. Never write Firestore queries directly in a page component — always put them in a service.

### The two ways to read data

**Once (Promise)** — use when you need a snapshot and don't need live updates:

```typescript
import { Firestore, doc, getDoc, collection, getDocs, query, where } from '@angular/fire/firestore';

// Single document
async getUserProfile(uid: string): Promise<UserProfile | null> {
  const ref = doc(this.firestore, `users/${uid}`);
  const snap = await getDoc(ref);
  return snap.exists() ? (snap.data() as UserProfile) : null;
}

// Multiple documents
async getPublicEvents(): Promise<Event[]> {
  const ref = collection(this.firestore, 'events');
  const q = query(ref, where('isPublished', '==', true));
  const snap = await getDocs(q);
  return snap.docs.map(d => ({ ...d.data(), id: d.id }) as Event);
}
```

**Real-time (Observable)** — use when the UI needs to update as data changes:

```typescript
import { docData, collectionData } from '@angular/fire/firestore';

// Single document — live
getPost(postId: string): Observable<Post | undefined> {
  const ref = doc(this.firestore, `posts/${postId}`);
  return docData(ref, { idField: 'id' }) as Observable<Post | undefined>;
}

// Collection — live
getComments(postId: string): Observable<Comment[]> {
  const ref = collection(this.firestore, 'comments');
  const q = query(ref, where('postId', '==', postId), orderBy('createdAt', 'asc'));
  return collectionData(q, { idField: 'id' }) as Observable<Comment[]>;
}
```

**In a page component**, subscribe to Observables in the template with `async` pipe (no manual subscribe/unsubscribe needed):

```html
<div *ngFor="let comment of comments$ | async">
  {{ comment.text }}
</div>
```

```typescript
comments$ = this.postService.getComments(this.postId);
```

### Writing data

```typescript
import {
  doc, addDoc, setDoc, updateDoc, deleteDoc,
  collection, serverTimestamp, increment
} from '@angular/fire/firestore';

// Create (auto-generated ID)
async createPost(data: Omit<Post, 'id' | 'createdAt'>): Promise<string> {
  const ref = collection(this.firestore, 'posts');
  const docRef = await addDoc(ref, {
    ...data,
    createdAt: serverTimestamp(),  // always use serverTimestamp, never new Date()
    updatedAt: serverTimestamp(),
  });
  return docRef.id;
}

// Create (specific ID)
async createWithId(userId: string, data: object): Promise<void> {
  const ref = doc(this.firestore, `users/${userId}`);
  await setDoc(ref, data);
}

// Update (partial)
async updateProfile(uid: string, changes: Partial<UserProfile>): Promise<void> {
  const ref = doc(this.firestore, `users/${uid}`);
  await updateDoc(ref, { ...changes, updatedAt: serverTimestamp() });
}

// Delete
async deletePost(postId: string): Promise<void> {
  const ref = doc(this.firestore, `posts/${postId}`);
  await deleteDoc(ref);
}

// Atomic counter (never read-then-write for counts)
await updateDoc(postRef, { likesCount: increment(1) });
await updateDoc(postRef, { likesCount: increment(-1) });
```

### Pagination pattern

This is how every list page in the app paginates. Study `post.service.ts` and `feed.page.ts` for the full example.

```typescript
// Service method
async getItems(
  pageLimit = 10,
  lastDoc?: QueryDocumentSnapshot
): Promise<{ items: MyModel[]; lastDoc: QueryDocumentSnapshot | null }> {
  let q = query(
    collection(this.firestore, 'my-collection'),
    orderBy('createdAt', 'desc'),
    limit(pageLimit)
  );
  if (lastDoc) {
    q = query(q, startAfter(lastDoc));
  }
  const snap = await getDocs(q);
  return {
    items: snap.docs.map(d => ({ ...d.data(), id: d.id }) as MyModel),
    lastDoc: snap.docs.length > 0 ? snap.docs[snap.docs.length - 1] : null,
  };
}
```

```typescript
// Page component
items: MyModel[] = [];
private lastDoc: QueryDocumentSnapshot | null = null;
hasMore = true;

async loadItems(reset = false): Promise<void> {
  if (reset) {
    this.lastDoc = null;
    this.hasMore = true;
  }
  const result = await this.myService.getItems(10, this.lastDoc ?? undefined);
  this.items = reset ? result.items : [...this.items, ...result.items];
  this.lastDoc = result.lastDoc;
  this.hasMore = result.items.length === 10;
}

// Pull-to-refresh
async onRefresh(event: CustomEvent): Promise<void> {
  await this.loadItems(true);
  event.detail.complete();
}

// Infinite scroll
async onInfiniteScroll(event: InfiniteScrollCustomEvent): Promise<void> {
  if (!this.hasMore) { await event.target.complete(); return; }
  await this.loadItems();
  await event.target.complete();
}
```

---

## 8. Data Models — TypeScript Interfaces

All models live in `src/app/models/`. Always import from the barrel file:

```typescript
import { UserProfile, Post, Comment, Event } from '../../models';
```

### Key models and their shapes

**UserProfile** — stored at `users/{uid}`:

```typescript
interface UserProfile {
  uid: string;
  email: string;
  displayName: string;
  artistName?: string;
  photoURL?: string;
  bio?: string;
  location?: string;
  specialties: ArtistSpecialty[];   // e.g. ['Dance', 'Music']
  followersCount: number;
  followingCount: number;
  postsCount: number;
  isVerified: boolean;
  isPro: boolean;
  isPublic: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

**Post** — stored at `posts/{postId}`:

```typescript
interface Post {
  id: string;
  authorId: string;
  author?: UserSummary;   // denormalized — not always present
  type: 'video' | 'image' | 'text' | 'audio';
  caption?: string;
  media: MediaItem[];
  tags: string[];
  likesCount: number;
  commentsCount: number;
  isPublic: boolean;
  createdAt: Timestamp;
}
```

### Adding a new model

1. Create `src/app/models/my-thing.model.ts`
2. Define your interface
3. Export it from `src/app/models/index.ts`

```typescript
// my-thing.model.ts
import { Timestamp } from '@angular/fire/firestore';

export interface MyThing {
  id: string;
  creatorId: string;
  title: string;
  isActive: boolean;
  createdAt: Timestamp;
}
```

```typescript
// models/index.ts — add this line
export * from './my-thing.model';
```

---

## 9. Styling — Ionic + Tailwind CSS

This project uses **both** styling systems at the same time.

### When to use what

| Use Ionic (`color=`, `fill=`, `slot=`) | Use Tailwind (`class=""`) |
|---------------------------------------|--------------------------|
| Component variants (primary/danger/success) | Layout (flex, grid, padding, margin) |
| Built-in Ionic states (active, disabled) | Typography (text size, weight, color) |
| Component slots (start/end) | Background, border, shadow |

### Color system

Colors are defined in two places that mirror each other:
- **Ionic variables**: `src/theme/variables.scss` — used by Ionic components
- **Tailwind config**: `tailwind.config.js` — used by Tailwind classes

| What | CSS Variable | Tailwind class |
|------|-------------|----------------|
| Primary blue | `var(--ion-color-primary)` | `text-primary-500`, `bg-primary-500` |
| App background | `var(--ion-background-color)` | `bg-dark` |
| Card background | — | `bg-dark-100` |
| Border | `var(--ion-border-color)` | `border-dark-200` |
| Muted text | — | `text-gray-400` |

### Common layout patterns used in this app

```html
<!-- Centered loading spinner -->
<div class="flex justify-center items-center h-40">
  <ion-spinner name="crescent"></ion-spinner>
</div>

<!-- Card -->
<div class="bg-dark-100 rounded-2xl p-4 mb-3 border border-dark-200">
  content
</div>

<!-- Row with avatar and text -->
<div class="flex items-center gap-3">
  <img class="w-10 h-10 rounded-full object-cover" [src]="user.photoURL" />
  <div>
    <p class="text-white font-semibold text-sm">{{ user.artistName }}</p>
    <p class="text-gray-400 text-xs">{{ user.location }}</p>
  </div>
</div>

<!-- Tag/chip row -->
<div class="flex flex-wrap gap-2">
  <span *ngFor="let tag of tags"
    class="px-3 py-1 rounded-full bg-dark-200 text-gray-300 text-xs">
    #{{ tag }}
  </span>
</div>
```

### Customizing Ionic component appearance

Ionic components expose CSS custom properties for styling. Set them via `style`:

```html
<ion-button style="--background: #0066FF; --border-radius: 14px; --color: white;">
  Post
</ion-button>

<ion-input style="--color: white; --placeholder-color: #4A4A4A; --background: #222;"></ion-input>
```

Find the full list of custom properties in the [Ionic docs](https://ionicframework.com/docs/components) for each component.

### Skeleton loaders

Use skeleton loaders for the initial load state — they're better UX than a spinner for list pages:

```html
<ng-container *ngIf="isLoading && items.length === 0">
  <div *ngFor="let i of [1,2,3]" class="p-4 mb-2">
    <ion-skeleton-text animated class="w-40 h-4 rounded mb-2"></ion-skeleton-text>
    <ion-skeleton-text animated class="w-full h-32 rounded-xl"></ion-skeleton-text>
  </div>
</ng-container>
```

---

## 10. Forms — Reactive Forms Pattern

All forms in this app use Angular Reactive Forms. Here is the complete pattern used in `create-post` and `edit-profile`.

### Setup

```typescript
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';

export class MyFormPage {
  private fb = inject(FormBuilder);

  form = this.fb.group({
    title: ['', [Validators.required, Validators.maxLength(100)]],
    description: [''],
    price: [0, [Validators.min(0)]],
  });
}
```

### Accessing values

```typescript
// In a submit handler
const title = this.form.value.title ?? '';
const price = this.form.value.price ?? 0;

// Patch values (e.g., loading existing data)
this.form.patchValue({
  title: existingItem.title,
  description: existingItem.description,
});
```

### Template wiring

```html
<form [formGroup]="form" (ngSubmit)="onSubmit()">

  <ion-input
    formControlName="title"
    placeholder="Enter title"
    class="input-field"
    style="--color: white; --placeholder-color: #4A4A4A;"
  ></ion-input>

  <!-- Validation error -->
  <p *ngIf="form.get('title')?.invalid && form.get('title')?.touched"
     class="text-red-400 text-xs mt-1">
    Title is required.
  </p>

  <ion-textarea
    formControlName="description"
    placeholder="Description..."
    rows="4"
  ></ion-textarea>

  <ion-button
    expand="block"
    type="submit"
    [disabled]="form.invalid || isSaving"
  >
    <ion-spinner *ngIf="isSaving" name="crescent" class="w-4 h-4 mr-2"></ion-spinner>
    Save
  </ion-button>

</form>
```

### Submit handler pattern

```typescript
isSaving = false;
private toastCtrl = inject(ToastController);

async onSubmit(): Promise<void> {
  if (this.form.invalid || this.isSaving) return;
  this.isSaving = true;
  try {
    await this.myService.create(this.form.value);
    await this.router.navigate(['/tabs/my-list']);
  } catch {
    const toast = await this.toastCtrl.create({
      message: 'Something went wrong. Try again.',
      duration: 3000,
      color: 'danger',
      position: 'top',
    });
    await toast.present();
  } finally {
    this.isSaving = false;  // always reset, even on error
  }
}
```

---

## 11. Firebase Auth Patterns

All auth logic is in `src/app/core/services/auth.service.ts`. Most pages only need two things from it.

### Get the current user

```typescript
private authService = inject(AuthService);

// Synchronous — use for one-off UID checks
const uid = this.authService.currentUser?.uid;

// Observable — use when your template needs to react to auth changes
readonly user$ = this.authService.currentUser$;
```

### Check auth in a page

```typescript
async ngOnInit(): Promise<void> {
  const uid = this.authService.currentUser?.uid;
  if (!uid) return;  // guard against loading if not logged in
  await this.loadData(uid);
}
```

### Show/hide UI based on auth

```html
<!-- Show only if this is the current user's profile -->
<ion-button *ngIf="profileUid === currentUid" routerLink="/edit-profile">
  Edit Profile
</ion-button>
```

### Auth guard — how it works

The guards in `src/app/core/guards/` are applied to routes in `app.routes.ts`. You should not need to change them, but understanding them helps:

```typescript
// auth.guard.ts — used on /tabs/** and detail routes
export const authGuard: CanActivateFn = () => {
  const auth = inject(Auth);
  const router = inject(Router);
  return authState(auth).pipe(
    take(1),
    map((user) => {
      if (user) return true;
      router.navigate(['/auth/login']);
      return false;
    })
  );
};
```

`take(1)` means: read the auth state once and complete. Without it the guard would stay subscribed forever.

---

## 12. File Uploads — Storage Service

All uploads go through `src/app/core/services/storage.service.ts`. Never call Firebase Storage directly from a page.

### Uploading a profile photo

```typescript
private storageService = inject(StorageService);
uploadProgress = 0;

// File comes from an <input type="file"> change event
async onPhotoSelected(event: Event): Promise<void> {
  const input = event.target as HTMLInputElement;
  if (!input.files?.length) return;

  // Resize before uploading (saves bandwidth and storage cost)
  const resized = await this.storageService.resizeImage(input.files[0], 500, 500, 0.8);

  const uid = this.authService.currentUser!.uid;
  this.storageService.uploadProfilePhoto(uid, resized).subscribe(async (progress) => {
    this.uploadProgress = progress.progress;
    if (progress.state === 'success' && progress.downloadURL) {
      await this.userService.updateProfile(uid, { photoURL: progress.downloadURL });
    }
  });
}
```

### Uploading post media

```typescript
async uploadMedia(file: File, postId: string): Promise<string | null> {
  const uid = this.authService.currentUser!.uid;
  const type = file.type.startsWith('video/') ? 'video' : 'image';

  return new Promise((resolve, reject) => {
    this.storageService.uploadPostMedia(uid, postId, file, type).subscribe({
      next: (progress) => {
        this.uploadProgress = progress.progress;
        if (progress.state === 'success') resolve(progress.downloadURL ?? null);
      },
      error: reject,
    });
  });
}
```

### Web file input pattern

On web, camera access uses a hidden file input. This is the pattern for any "pick a file" interaction:

```html
<!-- Hidden input, triggered programmatically -->
<input #fileInput type="file" accept="image/*,video/*" multiple
       class="hidden" (change)="onFileSelected($event)" />

<!-- Visible button -->
<button (click)="fileInput.click()" class="...">
  Add Photo
</button>
```

---

## 13. Cloud Functions

Cloud Functions run server-side in response to events. They live in `functions/src/`.

### Existing functions

| Function | Trigger | What it does |
|----------|---------|--------------|
| `onPostLiked` | New like doc created | Sends push notification + Firestore notification to post author |
| `onPostCommented` | New comment created | Same for comments |
| `onUserFollowed` | New follow created | Notifies followed user |
| `onMessageSent` | New message created | Notifies conversation partner |
| `onUserCreated` | New Firebase Auth user | Creates Firestore user profile |
| `onPostDeleted` | Post document deleted | Cleans up comments, likes, Storage files |
| `cleanupOldNotifications` | Weekly schedule | Deletes read notifications older than 30 days |
| `updateTrendingPosts` | Daily schedule | Recomputes trending post scores |

### Adding a new Firestore trigger

Create a new file in the appropriate subfolder of `functions/src/`:

```typescript
// functions/src/notifications/on-post-shared.ts
import * as functions from 'firebase-functions';
import { db } from '../index';
import * as admin from 'firebase-admin';

export const onPostShared = functions.firestore
  .document('shares/{shareId}')
  .onCreate(async (snapshot, context) => {
    const share = snapshot.data();
    const { shareId } = context.params;

    try {
      const postSnap = await db.doc(`posts/${share['postId']}`).get();
      if (!postSnap.exists) return;
      const post = postSnap.data()!;

      // Don't notify self-shares
      if (post['authorId'] === share['sharedBy']) return;

      await db.collection('notifications').add({
        recipientId: post['authorId'],
        senderId: share['sharedBy'],
        type: 'share',
        title: 'Your post was shared',
        body: `Someone shared your post`,
        data: { postId: share['postId'] },
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`Share notification sent for post ${share['postId']}`);
    } catch (error) {
      functions.logger.error('Error in onPostShared:', error);
    }
  });
```

Then export it from `functions/src/index.ts`:

```typescript
export * from './notifications/on-post-shared';
```

### Deploying functions

```bash
# Deploy only functions (faster than full deploy)
firebase deploy --only functions

# Deploy a specific function
firebase deploy --only functions:onPostShared
```

---

## 14. Platform Detection — Web vs Native

This app runs on web now, and will run on iOS/Android later via Capacitor. Some APIs behave differently. Use this pattern whenever you're using a Capacitor plugin:

```typescript
import { Capacitor } from '@capacitor/core';

if (Capacitor.isNativePlatform()) {
  // iOS / Android — use native Capacitor API
} else {
  // Web — use standard browser API
}
```

### Where this is already applied

**Auth service** — Google/Apple sign-in:
```typescript
if (Capacitor.isNativePlatform()) {
  await signInWithRedirect(this.auth, provider);   // native: redirect flow
} else {
  await signInWithPopup(this.auth, provider);      // web: popup window
}
```

**create-post** and **edit-profile** — file/photo picking:
```typescript
if (Capacitor.isNativePlatform()) {
  // Native: Capacitor Camera plugin (prompt for camera or library)
  const photo = await Camera.getPhoto({ ... });
} else {
  // Web: trigger hidden <input type="file">
  this.fileInput.nativeElement.click();
}
```

### APIs that are native-only (don't use these without a web fallback)

- `@capacitor/camera` — Camera.getPhoto()
- `@capacitor/push-notifications` — already guarded in notification.service.ts
- `@capacitor/haptics` — vibration, not available on web
- `@capacitor/app` — app lifecycle events (background/foreground)

If you add any of these, wrap them in `Capacitor.isNativePlatform()`.

---

## 15. Common Patterns Quick Reference

### Show a toast message

```typescript
private toastCtrl = inject(ToastController);

async showToast(message: string, color: 'success' | 'danger' | 'warning' = 'success'): Promise<void> {
  const toast = await this.toastCtrl.create({
    message,
    duration: 2500,
    color,
    position: 'top',
  });
  await toast.present();
}
```

### Show an alert dialog

```typescript
private alertCtrl = inject(AlertController);

async confirmDelete(): Promise<boolean> {
  return new Promise((resolve) => {
    this.alertCtrl.create({
      header: 'Delete post?',
      message: 'This cannot be undone.',
      buttons: [
        { text: 'Cancel', role: 'cancel', handler: () => resolve(false) },
        { text: 'Delete', role: 'destructive', handler: () => resolve(true) },
      ],
    }).then(alert => alert.present());
  });
}
```

### Using Ionicons

Every icon must be registered before use:

```typescript
import { addIcons } from 'ionicons';
import { heartOutline, heart, shareOutline } from 'ionicons/icons';

constructor() {
  addIcons({ heartOutline, heart, shareOutline });
}
```

```html
<ion-icon name="heart-outline"></ion-icon>
```

Find icon names at [ionic.io/ionicons](https://ionic.io/ionicons). The import name is camelCase (`heartOutline`), the template name is kebab-case (`heart-outline`).

### Handling loading states

Every data operation should have a loading flag:

```typescript
isLoading = false;

async loadData(): Promise<void> {
  this.isLoading = true;
  try {
    this.data = await this.service.getData();
  } finally {
    this.isLoading = false;  // runs even if there's an error
  }
}
```

### TrackBy for lists

Always use `trackBy` with `*ngFor` to prevent unnecessary DOM re-renders:

```typescript
trackById(_: number, item: { id: string }): string {
  return item.id;
}
```

```html
<app-post-card *ngFor="let post of posts; trackBy: trackById" [post]="post">
</app-post-card>
```

### Using the EmptyState component

Use it whenever a list could be empty:

```html
<app-empty-state
  *ngIf="!isLoading && items.length === 0"
  icon="albums-outline"
  title="No items yet"
  message="Be the first to add something."
></app-empty-state>
```

---

## 16. Things That Will Trip You Up

### ❌ Forgetting to import Ionic components

If a component renders as nothing in the browser:

```typescript
// ✅ Every Ionic component used in the template must be listed here
imports: [
  IonHeader, IonToolbar, IonTitle, IonContent,
  IonButton, IonIcon,  // ← forgot these? they won't render
]
```

### ❌ Using `new Date()` instead of `serverTimestamp()`

```typescript
// ❌ Wrong — client time can be wrong, causes ordering bugs
createdAt: new Date()

// ✅ Correct — server sets the time
createdAt: serverTimestamp()
```

### ❌ Reading then writing for counter fields

```typescript
// ❌ Wrong — race condition, two users could read the same value
const post = await getDoc(postRef);
const currentCount = post.data().likesCount;
await updateDoc(postRef, { likesCount: currentCount + 1 });

// ✅ Correct — Firestore handles this atomically
await updateDoc(postRef, { likesCount: increment(1) });
```

### ❌ Subscribing without unsubscribing

If you manually subscribe to an Observable (not using `async` pipe), you must unsubscribe:

```typescript
import { Subscription } from 'rxjs';

export class MyPage implements OnDestroy {
  private sub!: Subscription;

  ngOnInit() {
    this.sub = this.myService.getData().subscribe(data => this.data = data);
  }

  ngOnDestroy() {
    this.sub.unsubscribe();  // ← memory leak without this
  }
}
```

Or use the `async` pipe in the template instead — it handles cleanup automatically.

### ❌ Calling Capacitor plugins on web without a fallback

```typescript
// ❌ Wrong — crashes on web
const photo = await Camera.getPhoto({ ... });

// ✅ Correct — check platform first
if (Capacitor.isNativePlatform()) {
  const photo = await Camera.getPhoto({ ... });
} else {
  this.fileInput.nativeElement.click();
}
```

### ❌ Hardcoding user IDs or paths

```typescript
// ❌ Wrong — never hardcode
const ref = doc(this.firestore, 'users/abc123');

// ✅ Correct — always dynamic
const uid = this.authService.currentUser?.uid;
const ref = doc(this.firestore, `users/${uid}`);
```

### ❌ Forgetting `await` on async operations

```typescript
// ❌ Wrong — navigation runs before save completes
this.userService.updateProfile(uid, changes);
this.router.navigate(['/tabs/profile']);

// ✅ Correct
await this.userService.updateProfile(uid, changes);
await this.router.navigate(['/tabs/profile']);
```

---

## Checklist — Adding a New Feature

Use this when building anything new:

- [ ] Model defined in `src/app/models/` and exported from `index.ts`
- [ ] Service method added to appropriate service in `src/app/core/services/`
- [ ] Page component created (`.ts`, `.html`, `.scss`)
- [ ] All Ionic components added to the `imports` array in `@Component`
- [ ] Route registered in `app.routes.ts` with `authGuard`
- [ ] Loading state (`isLoading`) managed with `try/finally`
- [ ] Empty state shown when list is empty
- [ ] `trackBy` used on all `*ngFor` loops
- [ ] Any file picking / camera use has a web fallback
- [ ] `serverTimestamp()` used for all dates
- [ ] `increment()` used for all counter fields
- [ ] Toast shown on errors in catch blocks

---

*This guide covers the actual patterns used in the Rhythm Culture codebase. When in doubt, look at a working page — `feed.page.ts` and `edit-profile.page.ts` are good references for most common patterns.*
