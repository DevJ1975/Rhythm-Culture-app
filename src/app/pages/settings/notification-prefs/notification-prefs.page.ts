import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonList,
  IonItem,
  IonLabel,
  IonToggle,
  IonBackButton,
  IonButtons,
  IonSpinner,
} from '@ionic/angular/standalone';
import { AuthService } from '../../../core/services/auth.service';
import { UserService } from '../../../core/services/user.service';
import { NotificationService } from '../../../core/services/notification.service';
import { DEFAULT_NOTIFICATION_PREFS, NotificationPreferences } from '../../../models';

@Component({
  selector: 'app-notification-prefs',
  templateUrl: './notification-prefs.page.html',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterModule,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonList,
    IonItem,
    IonLabel,
    IonToggle,
    IonBackButton,
    IonButtons,
    IonSpinner,
  ],
})
export class NotificationPrefsPage implements OnInit {
  private auth = inject(AuthService);
  private users = inject(UserService);
  private notifications = inject(NotificationService);

  loading = true;
  saving = false;
  prefs: NotificationPreferences = { ...DEFAULT_NOTIFICATION_PREFS };

  items: { key: keyof NotificationPreferences; label: string; description: string }[] = [
    { key: 'likes', label: 'Likes', description: 'When someone likes your post' },
    { key: 'comments', label: 'Comments', description: 'When someone comments on your post' },
    { key: 'follows', label: 'New followers', description: 'When someone follows you' },
    { key: 'mentions', label: 'Mentions', description: 'When you’re tagged in a post or comment' },
    { key: 'messages', label: 'Direct messages', description: 'New conversations and replies' },
    { key: 'eventReminders', label: 'Event reminders', description: 'For events you’ve registered for' },
    { key: 'courseUpdates', label: 'Course updates', description: 'New lessons or announcements' },
    { key: 'marketing', label: 'Tips & promotions', description: 'Occasional product updates' },
  ];

  async ngOnInit(): Promise<void> {
    const uid = this.auth.currentUser?.uid;
    if (!uid) return;
    try {
      const profile = await this.users.getUserProfileOnce(uid);
      if (profile?.notificationPrefs) {
        this.prefs = { ...DEFAULT_NOTIFICATION_PREFS, ...profile.notificationPrefs };
      }
    } finally {
      this.loading = false;
    }
  }

  async toggle(key: keyof NotificationPreferences, value: boolean): Promise<void> {
    const uid = this.auth.currentUser?.uid;
    if (!uid) return;
    this.prefs = { ...this.prefs, [key]: value };
    this.saving = true;
    try {
      await this.notifications.updatePreferences(uid, this.prefs as unknown as Record<string, boolean>);
    } finally {
      this.saving = false;
    }
  }
}
