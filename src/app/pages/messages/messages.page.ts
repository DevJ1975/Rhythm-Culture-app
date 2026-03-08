import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonList, IonItem, IonAvatar, IonLabel, IonBadge, IonSearchbar, IonButtons,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { createOutline, searchOutline } from 'ionicons/icons';
import { Conversation } from '../../models';
import { MessagingService } from '../../core/services/messaging.service';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-messages',
  templateUrl: './messages.page.html',
  styleUrls: ['./messages.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonList, IonItem, IonAvatar, IonLabel, IonBadge, IonSearchbar, IonButtons,
  ],
})
export class MessagesPage implements OnInit {
  private messagingService = inject(MessagingService);
  private authService = inject(AuthService);

  conversations: Conversation[] = [];
  isLoading = true;

  constructor() {
    addIcons({ createOutline, searchOutline });
  }

  ngOnInit(): void {
    const uid = this.authService.currentUser?.uid;
    if (!uid) return;
    this.messagingService.getUserConversations(uid).subscribe((convs) => {
      this.conversations = convs;
      this.isLoading = false;
    });
  }

  getUnreadCount(conv: Conversation): number {
    const uid = this.authService.currentUser?.uid ?? '';
    return conv.unreadCounts?.[uid] ?? 0;
  }

  getOtherParticipant(conv: Conversation): any {
    const uid = this.authService.currentUser?.uid;
    return conv.participants?.find((p: any) => p.uid !== uid) ?? null;
  }

  formatTime(ts: any): string {
    if (!ts) return '';
    const d = ts?.toDate ? ts.toDate() : new Date(ts);
    const now = new Date();
    const diff = now.getTime() - d.getTime();
    if (diff < 86400000) return d.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    if (diff < 604800000) return d.toLocaleDateString('en-US', { weekday: 'short' });
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  }
}
