# Changelog

All notable changes to Rhythm Culture are documented here.

## [0.4.0] — 2026-04-12

### Performance
- Replaced all `DispatchQueue.main.asyncAfter` with Swift Concurrency (`Task` + `Task.sleep(for:)` + `MainActor.run`)
- Applied to `PostCellView` (heart animation hide) and `CreatePostView` (publish simulation)

### Documentation
- Added `README.md` with full feature list, project structure, revenue model, and pre-backend checklist
- Added `CHANGELOG.md`

---

## [0.3.0] — 2026-04-11

### Features: All Pre-Backend Screens

#### New Screens
- **PostDetailView** — full post with comments, `@FocusState` input bar, live comment insertion, NavigationLink to commenter profiles
- **MessagesView + MessageThreadView** — DM conversation list with unread badges, search, and full chat bubble thread with mic/send toggle
- **OnboardingView** — non-dismissable artist-type picker (9 types) shown on first login via `@AppStorage("hasCompletedOnboarding")`

#### Rewrites / Major Updates
- **SearchView** — ArtistType filter chips, Top Artists horizontal scroll with follow toggle, explore photo grid, live search across username/displayName/artistType, `SellerTierBadgeView` in `UserSearchRow`
- **NotificationsView** — grouped New/Earlier `List` sections, type-icon badge overlay on avatars, follow inline button, "Mark all read" toolbar action, uses `MockData.notifications`
- **CreatePostView** — media placeholder with camera/gallery/video, post type chips for all 5 `Post.PostType` cases, `TextEditor` with 2200-char counter, genre field, meta rows, animated Share button with `ProgressView`
- **FeedView** — `NavigationLink` wrapping each post to `PostDetailView`, `+` button → `CreatePostView` sheet, paperplane → `MessagesView` sheet, pull-to-refresh, `navigationDestination(for: AppUser.self)`

#### Models
- **`Comment`** — `Identifiable, Codable`; maps to Firestore `posts/{postId}/comments` subcollection
- **`AppUser`** — added `Hashable` conformance for `navigationDestination`
- **`Post.PostType`** — added `CaseIterable` conformance for `ForEach` in `CreatePostView`

#### MockData
- `MockData.allUsers` — 7 full `AppUser` objects (travispayne, missy.elliott, fik.shun, laurieann.g, boogaloo.shrimp, dj.jazzy.jeff, taeyang)
- `MockData.user(forId:)` helper
- `MockData.comments(for postId:)` — 6 mock comments, shuffled per post
- `MockData.notifications` — 8 `MockNotification` entries covering all 6 notification types

#### Bug Fixes
- Fixed `foregroundStyle(.primary : .white)` type ambiguity in `NotificationsView`, `SearchView`, `MessagesView` — wrapped both branches with `AnyShapeStyle`

---

## [0.2.0] — 2026-04-10

### Features: Seller Tiers + Dark Mode + Studio Expansion

#### Seller Tiers
- New `SellerTier` enum (`upAndComing`, `established`, `elite`) — `Codable, Comparable, CaseIterable, Identifiable`
- Thresholds: Elite = 800+ sales, Established = 100–799, Up & Coming = 1–99
- RC fee splits: Elite 10%, Established 13%, Up & Coming 15%
- New `SellerTierBadgeView` — compact capsule and full card with perks checklist
- Tier badges shown on: `PostCellView`, `ProfileView`, `UserSearchRow`, `StoreItemCardView`, `StoreItemDetailView`
- `MockData.sellerTier(forUserId:)` helper
- `StoreItem` updated with stored `sellerTier` property

#### Dark Mode
- `@AppStorage("isDarkMode")` in `ProfileView` and `SettingsSheet`
- `.preferredColorScheme(isDarkMode ? .dark : .light)` applied to root `NavigationStack` — affects entire app
- Hamburger button in `ProfileView` opens `SettingsSheet` with toggle + account rows + version info

#### Studio Tab Expansion
- Replaced 2-item `Picker` with 5-item scrollable tab strip: Masterclasses, Store, Coaching, Consulting, Shows
- Added `CoachingHubView`, `ConsultingHubView`, `ShowCreationHubView`
- Models: `CoachingListing`, `ConsultingListing`, `ShowListing`
- Elite Picks horizontal strip in Store with gold border on Elite seller cards
- `SellerTierCardView` shown in `StoreItemDetailView` with tier perks and fee split

#### Visual Polish
- Restored "Rhythm Culture" header logo to purple `foregroundStyle(.purple)`
- Changed header font to sans-serif (system default)

---

## [0.1.0] — 2026-04-09

### Features: Full Platform Foundation

#### Navigation
- 5-tab `MainTabView`: Home, Studio, Battles, Connect, Profile
- Spaces: horizontal strip between Stories and posts in Home feed (not a top-level tab)

#### New Models
- `Space` — live audio rooms (hostId, title, speakerUsernames, listenerCount, isLive, scheduledFor)
- `Masterclass` — paid video courses (instructorId, price, rating, enrolledCount, lessonCount)
- `StoreItem` + `StoreItemType` + `LicenseType` — beats, tracks, samples, merch with BPM/key
- `LiveStream` — live video streams (hostId, viewerCount, isActive)
- `Audition` — talent calls (lookingFor: [ArtistType], compensation, deadline, location)

#### New Views
- **Spaces**: `SpacesStripView` (horizontal cards in feed), `SpaceRoomView` (full room)
- **Studio**: `StudioView` shell, `MasterclassHubView`, `MasterclassCardView`, `MasterclassDetailView`, `StoreHubView`, `StoreItemCardView`, `StoreItemDetailView`
- **Live**: `LiveStreamView` (full-screen with gifts + comments), `GoLiveView`
- **Connect**: `ConnectView` shell, `AuditionsView`, `AuditionCardView`, `AuditionDetailView`
- **Profile**: Go Live button, pulsing LIVE ring badge on avatar

#### MockData
- 4 active Spaces (dance/rap/vocal topics)
- 6 Masterclasses (Travis Payne, Missy Elliott, Fik-Shun, Laurieann Gibson, Boogaloo, DJ Jazzy Jeff)
- 8 StoreItems (4 beats with BPM/key/license, 2 music tracks, 2 sample packs)
- 2 active LiveStreams
- 4 Auditions (Broadway, world tour, music video, festival)

---

## [0.0.1] — Initial Commit

### Foundation
- Project scaffolding — Xcode target, Info.plist, `Rythym_CultureApp.swift`
- Core models: `AppUser`, `ArtistType`, `Post`, `StoryItem`, `Challenge`, `CollabRequest`
- Views: `LoginView`, `SignUpView`, `AuthViewModel`, `FeedView`, `MainTabView`, `PostCellView`, `StoriesRowView`, `BattlesView`, `ChallengeCardView`, `CollabBoardView`, `ProfileView`, `SearchView`, `NotificationsView`, `CreatePostView`
- Utilities: `RemoteImage`, `ArtistBadgeView`, `Date+Extensions`, `MockData`
