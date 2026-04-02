import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonList, IonItem, IonAvatar, IonLabel, IonButtons,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  heart, chatbubble, personAdd, mail, calendarOutline,
  checkmarkDoneOutline, notificationsOutline,
} from 'ionicons/icons';
import { Notification, NotificationType } from '../../models';
import { NotificationService } from '../../core/services/notification.service';
import { AuthService } from '../../core/services/auth.service';
import { MockDataService } from '../../core/services/mock-data.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-notifications',
  templateUrl: './notifications.page.html',
  styleUrls: ['./notifications.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonList, IonItem, IonAvatar, IonLabel, IonButtons,
  ],
})
export class NotificationsPage implements OnInit {
  private notifService = inject(NotificationService);
  private authService = inject(AuthService);
  private mockData = inject(MockDataService);

  notifications: Notification[] = [];
  isLoading = true;

  constructor() {
    addIcons({ heart, chatbubble, personAdd, mail, calendarOutline, checkmarkDoneOutline, notificationsOutline });
  }

  ngOnInit(): void {
    if (!environment.production) {
      this.notifications = this.mockData.getNotifications();
      this.isLoading = false;
      return;
    }
    const uid = this.authService.currentUser?.uid;
    if (!uid) return;
    this.notifService.getAllNotifications(uid).subscribe((notifs) => {
      this.notifications = notifs;
      this.isLoading = false;
    });
  }

  async markAllRead(): Promise<void> {
    const uid = this.authService.currentUser?.uid;
    if (uid) await this.notifService.markAllAsRead(uid);
  }

  async markRead(notif: Notification): Promise<void> {
    if (!notif.isRead) await this.notifService.markAsRead(notif.id);
  }

  getIcon(type: NotificationType): string {
    const map: Record<NotificationType, string> = {
      like: 'heart',
      comment: 'chatbubble',
      follow: 'person-add',
      message: 'mail',
      collab_invite: 'people',
      collab_accepted: 'checkmark-circle',
      event_reminder: 'calendar-outline',
      course_update: 'play-circle',
      mention: 'at',
      new_post: 'image',
    };
    return map[type] ?? 'notifications-outline';
  }

  getIconColor(type: NotificationType): string {
    const map: Record<NotificationType, string> = {
      like: 'text-red-400',
      comment: 'text-blue-400',
      follow: 'text-green-400',
      message: 'text-primary-400',
      collab_invite: 'text-purple-400',
      collab_accepted: 'text-green-400',
      event_reminder: 'text-yellow-400',
      course_update: 'text-orange-400',
      mention: 'text-primary-400',
      new_post: 'text-primary-400',
    };
    return map[type] ?? 'text-gray-400';
  }

  formatTime(ts: any): string {
    const d = ts?.toDate ? ts.toDate() : new Date(ts);
    const diff = Date.now() - d.getTime();
    if (diff < 3600000) return Math.floor(diff / 60000) + 'm ago';
    if (diff < 86400000) return Math.floor(diff / 3600000) + 'h ago';
    return Math.floor(diff / 86400000) + 'd ago';
  }
}
