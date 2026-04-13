# Rhythm Culture

A production-ready iOS social platform for performing artists — dancers, singers, rappers, DJs, producers, and photographers.

## Overview

Rhythm Culture is the home platform for performing artists to share work, battle, collaborate, learn, sell, and grow. It combines the social discovery of Instagram with dedicated tools built exclusively for the performing arts ecosystem.

## Tech Stack

- **Platform**: iOS 17+ (Swift 5.9, SwiftUI)
- **Architecture**: MVVM, SwiftUI-first
- **State Management**: `@State`, `@AppStorage`, `@Environment`, `@Observable`
- **Async**: Swift Concurrency (`async/await`, `Task`, `MainActor`)
- **Backend (planned)**: Firebase Auth + Firestore + Storage
- **Images**: `AsyncImage` via `RemoteImage` wrapper with loading/error states

## Features

### Social Feed
- Home feed with Stories, active Spaces strip, and post stream
- Post types: Standard, New Drop, Battle Entry, Showcase, Collab Request
- Vibe reactions: Fire, Move, Vibes, Respect — with animated picker
- Double-tap to like with heart animation
- Pull-to-refresh

### Spaces (Live Audio)
- Active Spaces horizontal strip in the Home feed
- Full room view: host/speaker grid, listener count, mic request
- Scheduled and live rooms

### Studio Tab
Five content verticals in a scrollable tab strip:
| Tab | Description | RC Revenue |
|---|---|---|
| Masterclasses | Paid video courses from artists | 20% of each sale |
| Store | Beats, tracks, samples, merch | 15% platform fee |
| Coaching | 1-on-1 sessions with working artists | 15% platform fee |
| Consulting | Business/career consulting | 15% platform fee |
| Shows | Live event listings and tickets | 10% of ticket sales |

### Seller Tiers
Three-tier system for store sellers, displayed as profile badges:
- **Elite** (800+ total sales) — 10% RC fee, gold badge
- **Established** (100–799 sales) — 13% RC fee, blue badge
- **Up & Coming** (1–99 sales) — 15% RC fee, green badge

### Battles
- Active challenge cards with vote counts and time remaining
- Head-to-head comparison layout
- Battle entry post type in feed

### Connect Tab
- **Collabs**: Browse and post collaboration requests by artist type
- **Auditions**: Formal talent calls for tours, music videos, Broadway, festivals
  - Compensation display, deadline badges (red when < 3 days), in-app apply flow

### Live Streaming
- Go Live from profile with title input and camera preview
- Full-screen live view: video feed, viewer count, comment stream, gift button
- Pulsing LIVE ring on avatar when streaming
- Virtual gifts (RC takes 30% of gift revenue)

### Profile
- Artist type badge + seller tier badge
- Post grid with Reels/Tagged tabs
- Go Live button
- Dark mode toggle (persists app-wide via `@AppStorage`)
- Settings sheet: notifications, privacy, help

### Messages
- Conversation list with unread badges and search
- Thread view with chat bubbles, mic/send toggle

### Notifications
- Grouped New / Earlier sections
- Notification types: Like, Comment, Follow, Battle Vote, Collab Apply, Space Invite
- Mark all read action

### Onboarding
- Artist type selection (9 types) shown as non-dismissable sheet on first login
- Persisted via `@AppStorage("hasCompletedOnboarding")`

### Search / Explore
- ArtistType filter chips
- Top Artists horizontal scroll with follow toggle
- Explore photo grid (Instagram-style)
- Live search across username, display name, and artist type

## Project Structure

```
Rythym Culture/
├── Core/
│   ├── Authentication/        # Login, SignUp, AuthViewModel
│   ├── Battles/               # BattlesView, ChallengeCardView
│   ├── Collabs/               # CollabBoardView
│   ├── Connect/               # ConnectView (Collabs + Auditions)
│   ├── Auditions/             # AuditionsView, AuditionCardView
│   ├── CreatePost/            # CreatePostView
│   ├── Feed/                  # FeedView, MainTabView, PostCellView, PostDetailView, StoriesRowView
│   ├── Live/                  # LiveStreamView, GoLiveView
│   ├── Messages/              # MessagesView, MessageThreadView
│   ├── Notifications/         # NotificationsView
│   ├── Onboarding/            # OnboardingView
│   ├── Profile/               # ProfileView, SettingsSheet
│   ├── Search/                # SearchView
│   ├── Spaces/                # SpacesStripView, SpaceRoomView
│   └── Studio/                # StudioView, MasterclassHub, StoreHub, CoachingHub, ConsultingHub, ShowsHub
├── Models/
│   ├── AppUser.swift
│   ├── ArtistType.swift
│   ├── Audition.swift
│   ├── Challenge.swift
│   ├── CoachingListing.swift
│   ├── CollabRequest.swift
│   ├── Comment.swift
│   ├── ConsultingListing.swift
│   ├── LiveStream.swift
│   ├── Masterclass.swift
│   ├── Post.swift
│   ├── SellerTier.swift
│   ├── ShowListing.swift
│   ├── Space.swift
│   ├── StoreItem.swift
│   └── StoryItem.swift
└── Utilities/
    ├── ArtistBadgeView.swift
    ├── Date+Extensions.swift
    ├── EmptyStateView.swift
    ├── MockData.swift
    ├── RemoteImage.swift
    └── SellerTierBadgeView.swift
```

## Setup

1. Clone the repo
2. Open `Rythym Culture.xcodeproj` in Xcode 15+
3. Select a simulator or device running iOS 17+
4. Build and run (`Cmd+R`)

No dependencies or package manager required — all UI runs on mock data.

## Pre-Backend Checklist

All UI screens are complete. Before connecting Firebase:

- [ ] Add `GoogleService-Info.plist` (Firebase project)
- [ ] Replace `MockData` with real Firestore reads/writes
- [ ] Implement `AuthViewModel` sign-in/sign-up with `FirebaseAuth`
- [ ] Add `StorageService` for photo/video upload
- [ ] Replace `@AppStorage` dark mode with Firestore user preferences
- [ ] Implement push notifications (APNs + FCM)
- [ ] Replace all `MockData.avatarURL()` / Picsum / Pravatar with Firebase Storage URLs
- [ ] Add `StoreService` for in-app purchases (StoreKit 2)
- [ ] Add real-time listeners for Spaces and Live streams

## Revenue Model

| Feature | RC Cut |
|---|---|
| Masterclass sales | 20% |
| Store items (beats, samples, tracks, merch) | 15% |
| Coaching sessions | 15% |
| Consulting engagements | 15% |
| Event/show ticket sales | 10% |
| Virtual gifts on Live | 30% |
| Ticketed Spaces (planned) | 10% |
