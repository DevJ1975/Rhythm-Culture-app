# Rhythm Culture - Architecture Overview

## Platform
Mobile-first social platform for the global performing arts community.

## Tech Stack
- **Frontend**: Angular 17 (Standalone), Ionic 7, Capacitor 5, Tailwind CSS 3
- **Backend**: Firebase (Auth, Firestore, Storage, Functions, Hosting)
- **Language**: TypeScript
- **Deployment**: Firebase Hosting (web) + Capacitor (iOS/Android)

---

## Folder Structure

```
Rhythm-Culture-app/
├── src/
│   ├── app/
│   │   ├── core/
│   │   │   ├── services/       # AuthService, PostService, UserService, ...
│   │   │   └── guards/         # authGuard, noAuthGuard
│   │   ├── models/             # TypeScript interfaces for all data
│   │   ├── pages/
│   │   │   ├── auth/           # Login, Register, ForgotPassword
│   │   │   ├── tabs/           # Bottom tab bar layout
│   │   │   ├── feed/           # Social feed
│   │   │   ├── discover/       # Search artists & collaborations
│   │   │   ├── profile/        # User profile & edit profile
│   │   │   ├── create-post/    # Post creation
│   │   │   ├── post-detail/    # Post with comments
│   │   │   ├── masterclass/    # Courses & lessons
│   │   │   ├── events/         # Events & registration
│   │   │   ├── messages/       # DMs & conversation
│   │   │   ├── collaboration/  # Collaboration hub
│   │   │   └── notifications/  # Notification center
│   │   └── shared/
│   │       └── components/     # PostCard, UserAvatar, SpecialtyBadge, EmptyState
│   ├── environments/           # Firebase config per environment
│   └── theme/                  # Ionic CSS variables
├── functions/
│   └── src/
│       ├── notifications/      # Like, comment, follow, message triggers
│       ├── users/              # Auth user create/delete handlers
│       ├── posts/              # Post delete cleanup
│       └── scheduled/          # Cleanup & trending jobs
├── firestore.rules             # Firestore security rules
├── firestore.indexes.json      # Composite indexes
├── storage.rules               # Firebase Storage security rules
├── firebase.json               # Firebase project config
├── angular.json                # Angular CLI config
├── tailwind.config.js          # Tailwind CSS config
└── capacitor.config.ts         # Capacitor mobile config
```

---

## Firestore Schema

### `users/{uid}`
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "artistName": "string",
  "photoURL": "string | null",
  "coverPhotoURL": "string | null",
  "bio": "string",
  "location": "string",
  "specialties": ["Dance", "Music", ...],
  "socialLinks": { "instagram": "...", "youtube": "..." },
  "followersCount": 0,
  "followingCount": 0,
  "postsCount": 0,
  "isVerified": false,
  "isPro": false,
  "isPublic": true,
  "fcmTokens": ["token1", "token2"],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### `posts/{postId}`
```json
{
  "id": "string",
  "authorId": "string",
  "type": "video | image | text | audio",
  "caption": "string",
  "media": [{ "url": "...", "thumbnailUrl": "...", "type": "...", "storagePath": "..." }],
  "tags": ["hiphop", "dance"],
  "likesCount": 0,
  "commentsCount": 0,
  "sharesCount": 0,
  "isPublic": true,
  "createdAt": "Timestamp"
}
```

Subcollections: `posts/{postId}/likes/{userId}`

### `comments/{commentId}`
```json
{
  "postId": "string",
  "authorId": "string",
  "text": "string",
  "likesCount": 0,
  "parentCommentId": "string | null",
  "createdAt": "Timestamp"
}
```

### `conversations/{conversationId}`
```json
{
  "participantIds": ["uid1", "uid2"],
  "lastMessage": "string",
  "lastMessageAt": "Timestamp",
  "unreadCounts": { "uid1": 0, "uid2": 2 },
  "createdAt": "Timestamp"
}
```

Subcollections: `conversations/{id}/messages/{messageId}`

### `events/{eventId}`
```json
{
  "organizerId": "string",
  "title": "string",
  "category": "Workshop | Battle | Concert ...",
  "format": "in-person | virtual | hybrid",
  "location": { "venue": "...", "city": "...", "country": "..." },
  "eventDate": "Timestamp",
  "price": 0,
  "isFree": true,
  "currentAttendees": 0,
  "isPublished": true
}
```

### `courses/{courseId}`
```json
{
  "instructorId": "string",
  "title": "string",
  "category": "Dance | Music ...",
  "level": "beginner | intermediate | advanced",
  "price": 0,
  "isFree": true,
  "lessonsCount": 0,
  "enrolledCount": 0,
  "rating": 0,
  "status": "published"
}
```

Subcollections: `courses/{id}/lessons/{lessonId}`

### `collaborations/{collabId}`
```json
{
  "creatorId": "string",
  "title": "string",
  "type": "Project | Casting Call | Looking For ...",
  "skills": ["Dance", "Music"],
  "isRemote": true,
  "isPaid": false,
  "status": "open | closed",
  "currentApplicants": 0
}
```

### `notifications/{notifId}`
```json
{
  "recipientId": "string",
  "senderId": "string",
  "type": "like | comment | follow | message ...",
  "title": "string",
  "body": "string",
  "data": { "postId": "...", "conversationId": "..." },
  "isRead": false,
  "createdAt": "Timestamp"
}
```

---

## Setup Instructions

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named `rhythm-culture-app`
3. Enable Authentication (Email/Password, Google, Apple)
4. Enable Firestore Database (start in production mode)
5. Enable Storage
6. Enable Functions (requires Blaze plan)

### 2. Configure Environment
Edit `src/environments/environment.ts` with your Firebase config:
```typescript
export const environment = {
  production: false,
  firebase: {
    apiKey: 'your-api-key',
    authDomain: 'your-project.firebaseapp.com',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    messagingSenderId: 'your-sender-id',
    appId: 'your-app-id',
  },
};
```

### 3. Install Dependencies
```bash
npm install
cd functions && npm install && cd ..
```

### 4. Deploy Firebase Rules & Indexes
```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

### 5. Run Locally
```bash
# Web
npm start

# With Firebase emulators
firebase emulators:start
```

### 6. Build & Deploy
```bash
# Build the app
npm run build:prod

# Deploy everything
firebase deploy
```

### 7. Mobile (Capacitor)
```bash
# Sync to native projects
npm run cap:sync

# Open Android Studio
npm run cap:android

# Open Xcode
npm run cap:ios
```

---

## Cloud Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `onPostLiked` | Firestore onCreate (likes) | Notify post author of new like |
| `onPostCommented` | Firestore onCreate (comments) | Notify post author of new comment |
| `onUserFollowed` | Firestore onCreate (follows) | Notify followed user |
| `onMessageSent` | Firestore onCreate (messages) | Notify message recipient |
| `onUserCreated` | Auth onCreate | Create Firestore user profile |
| `onUserDeleted` | Auth onDelete | Soft-delete user data |
| `onPostDeleted` | Firestore onDelete (posts) | Clean up comments, likes, storage |
| `cleanupOldNotifications` | Scheduled (weekly) | Remove read notifications > 30 days |
| `updateTrendingPosts` | Scheduled (daily) | Compute trending posts |

---

## Security Model
- All Firestore reads/writes require authentication
- Users can only write to their own documents
- Posts/events/collaborations can be read by all authenticated users
- Messages only accessible to conversation participants
- Service account keys never exposed to client (Functions only)

---

## Color Palette
| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#0066FF` | Accent, CTAs, highlights |
| Background | `#0A0A0A` | App background |
| Surface | `#1A1A1A` | Cards, modals |
| Input | `#222222` | Form inputs |
| Border | `#2A2A2A` | Dividers, borders |
| Text | `#FFFFFF` | Primary text |
| Muted | `#6B7280` | Secondary text |
