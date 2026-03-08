import { Component, OnInit, inject, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute } from '@angular/router';
import { FormsModule } from '@angular/forms';
import {
  IonHeader, IonToolbar, IonContent, IonFooter, IonButton, IonIcon,
  IonButtons, IonAvatar, IonTextarea,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { chevronBackOutline, sendOutline, imageOutline, micOutline } from 'ionicons/icons';
import { Message, Conversation } from '../../../models';
import { MessagingService } from '../../../core/services/messaging.service';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-conversation',
  templateUrl: './conversation.page.html',
  styleUrls: ['./conversation.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterModule, FormsModule,
    IonHeader, IonToolbar, IonContent, IonFooter, IonButton, IonIcon,
    IonButtons, IonAvatar, IonTextarea,
  ],
})
export class ConversationPage implements OnInit {
  private messagingService = inject(MessagingService);
  private authService = inject(AuthService);
  private route = inject(ActivatedRoute);

  @ViewChild(IonContent) content!: IonContent;

  messages: Message[] = [];
  messageText = '';
  conversationId = '';
  isSending = false;

  constructor() {
    addIcons({ chevronBackOutline, sendOutline, imageOutline, micOutline });
  }

  ngOnInit(): void {
    this.conversationId = this.route.snapshot.paramMap.get('conversationId')!;
    const uid = this.authService.currentUser?.uid;

    this.messagingService.getMessages(this.conversationId).subscribe((msgs) => {
      this.messages = msgs.reverse();
      setTimeout(() => this.content?.scrollToBottom(300), 100);
    });

    if (uid) {
      this.messagingService.markConversationAsRead(this.conversationId, uid);
    }
  }

  async sendMessage(): Promise<void> {
    const text = this.messageText.trim();
    if (!text || this.isSending) return;
    const uid = this.authService.currentUser?.uid;
    if (!uid) return;

    this.messageText = '';
    this.isSending = true;
    try {
      await this.messagingService.sendMessage(this.conversationId, {
        conversationId: this.conversationId,
        senderId: uid,
        type: 'text',
        text,
        isRead: false,
        isDeleted: false,
      });
    } finally {
      this.isSending = false;
    }
  }

  isOwnMessage(msg: Message): boolean {
    return msg.senderId === this.authService.currentUser?.uid;
  }

  formatTime(ts: any): string {
    if (!ts) return '';
    const d = ts?.toDate ? ts.toDate() : new Date(ts);
    return d.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
  }

  trackById(_: number, msg: Message): string {
    return msg.id;
  }
}
