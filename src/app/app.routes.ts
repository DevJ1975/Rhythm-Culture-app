import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { noAuthGuard } from './core/guards/no-auth.guard';
import { verifiedGuard } from './core/guards/verified.guard';
import { adminGuard } from './core/guards/admin.guard';

export const routes: Routes = [
  {
    path: '',
    redirectTo: '/tabs/feed',
    pathMatch: 'full',
  },
  // ── Auth (unauthenticated) ─────────────────────────────────────────────────
  {
    path: 'auth',
    canActivate: [noAuthGuard],
    children: [
      {
        path: 'login',
        loadComponent: () =>
          import('./pages/auth/login/login.page').then((m) => m.LoginPage),
      },
      {
        path: 'register',
        loadComponent: () =>
          import('./pages/auth/register/register.page').then(
            (m) => m.RegisterPage
          ),
      },
      {
        path: 'forgot-password',
        loadComponent: () =>
          import('./pages/auth/forgot-password/forgot-password.page').then(
            (m) => m.ForgotPasswordPage
          ),
      },
      {
        path: '',
        redirectTo: 'login',
        pathMatch: 'full',
      },
    ],
  },
  // ── Verify Email (signed in but unverified) ───────────────────────────────
  {
    path: 'auth/verify-email',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/auth/verify-email/verify-email.page').then(
        (m) => m.VerifyEmailPage
      ),
  },
  // ── Payment & Upgrade ─────────────────────────────────────────────────────
  {
    path: 'upgrade',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/upgrade/upgrade.page').then((m) => m.UpgradePage),
  },
  {
    path: 'payment-success',
    canActivate: [authGuard],
    data: { outcome: 'success' },
    loadComponent: () =>
      import('./pages/payment-result/payment-result.page').then(
        (m) => m.PaymentResultPage
      ),
  },
  {
    path: 'payment-cancel',
    canActivate: [authGuard],
    data: { outcome: 'cancel' },
    loadComponent: () =>
      import('./pages/payment-result/payment-result.page').then(
        (m) => m.PaymentResultPage
      ),
  },
  {
    path: 'admin',
    canActivate: [authGuard, adminGuard],
    loadComponent: () =>
      import('./pages/admin/admin.page').then((m) => m.AdminPage),
  },
  {
    path: 'admin/moderation',
    canActivate: [authGuard, adminGuard],
    loadComponent: () =>
      import('./pages/admin/moderation-queue/moderation-queue.page').then(
        (m) => m.ModerationQueuePage
      ),
  },
  {
    path: 'search',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/search/search.page').then((m) => m.SearchPage),
  },
  {
    path: 'hashtag/:tag',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/hashtag/hashtag.page').then((m) => m.HashtagPage),
  },
  {
    path: 'settings/notifications',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/settings/notification-prefs/notification-prefs.page').then(
        (m) => m.NotificationPrefsPage
      ),
  },
  {
    path: 'settings/language',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/settings/language/language.page').then(
        (m) => m.LanguagePage
      ),
  },
  // ── Main App (authenticated, tab layout) ─────────────────────────────────
  {
    path: 'tabs',
    canActivate: [authGuard, verifiedGuard],
    loadComponent: () =>
      import('./pages/tabs/tabs.page').then((m) => m.TabsPage),
    children: [
      {
        path: 'feed',
        loadComponent: () =>
          import('./pages/feed/feed.page').then((m) => m.FeedPage),
      },
      {
        path: 'discover',
        loadComponent: () =>
          import('./pages/discover/discover.page').then((m) => m.DiscoverPage),
      },
      {
        path: 'create',
        loadComponent: () =>
          import('./pages/create-post/create-post.page').then(
            (m) => m.CreatePostPage
          ),
      },
      {
        path: 'masterclass',
        loadComponent: () =>
          import('./pages/masterclass/masterclass.page').then(
            (m) => m.MasterclassPage
          ),
      },
      {
        path: 'profile',
        loadComponent: () =>
          import('./pages/profile/profile.page').then((m) => m.ProfilePage),
      },
      {
        path: '',
        redirectTo: 'feed',
        pathMatch: 'full',
      },
    ],
  },
  // ── Deep Routes (authenticated) ──────────────────────────────────────────
  {
    path: 'profile/:uid',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/profile/profile.page').then((m) => m.ProfilePage),
  },
  {
    path: 'edit-profile',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/profile/edit-profile/edit-profile.page').then(
        (m) => m.EditProfilePage
      ),
  },
  {
    path: 'collaboration',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/collaboration/collaboration.page').then(
        (m) => m.CollaborationPage
      ),
  },
  {
    path: 'collaboration/:id',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/collaboration/collaboration-detail/collaboration-detail.page').then(
        (m) => m.CollaborationDetailPage
      ),
  },
  {
    path: 'events',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/events/events.page').then((m) => m.EventsPage),
  },
  {
    path: 'events/:id',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/events/event-detail/event-detail.page').then(
        (m) => m.EventDetailPage
      ),
  },
  {
    path: 'masterclass/:id',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/masterclass/course-detail/course-detail.page').then(
        (m) => m.CourseDetailPage
      ),
  },
  {
    path: 'messages',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/messages/messages.page').then((m) => m.MessagesPage),
  },
  {
    path: 'messages/:conversationId',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/messages/conversation/conversation.page').then(
        (m) => m.ConversationPage
      ),
  },
  {
    path: 'notifications',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/notifications/notifications.page').then(
        (m) => m.NotificationsPage
      ),
  },
  {
    path: 'post/:id',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/post-detail/post-detail.page').then(
        (m) => m.PostDetailPage
      ),
  },
  {
    path: 'create-story',
    canActivate: [authGuard, verifiedGuard],
    loadComponent: () =>
      import('./pages/create-story/create-story.page').then(
        (m) => m.CreateStoryPage
      ),
  },
  // ── Fallback ──────────────────────────────────────────────────────────────
  {
    path: '**',
    redirectTo: '/tabs/feed',
  },
];
