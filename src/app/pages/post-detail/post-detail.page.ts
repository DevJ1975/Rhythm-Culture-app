import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute } from '@angular/router';
import { FormsModule } from '@angular/forms';
import {
  IonHeader, IonToolbar, IonContent, IonButton, IonIcon,
  IonButtons, IonFooter, IonInput, IonList, IonItem, IonAvatar, IonLabel,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { chevronBackOutline, sendOutline } from 'ionicons/icons';
import { Post, Comment } from '../../models';
import { PostService } from '../../core/services/post.service';
import { AuthService } from '../../core/services/auth.service';
import { PostCardComponent } from '../../shared/components/post-card/post-card.component';

@Component({
  selector: 'app-post-detail',
  templateUrl: './post-detail.page.html',
  standalone: true,
  imports: [
    CommonModule, RouterModule, FormsModule,
    IonHeader, IonToolbar, IonContent, IonButton, IonIcon,
    IonButtons, IonFooter, IonInput, IonList, IonItem, IonAvatar, IonLabel,
    PostCardComponent,
  ],
})
export class PostDetailPage implements OnInit {
  private postService = inject(PostService);
  private authService = inject(AuthService);
  private route = inject(ActivatedRoute);

  post: Post | null = null;
  comments: Comment[] = [];
  commentText = '';
  isSending = false;

  constructor() {
    addIcons({ chevronBackOutline, sendOutline });
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.postService.getPostById(id).subscribe((p) => {
      this.post = p ?? null;
    });
    this.postService.getComments(id).subscribe((comments) => {
      this.comments = comments;
    });
  }

  async sendComment(): Promise<void> {
    const text = this.commentText.trim();
    if (!text || !this.post || this.isSending) return;
    const uid = this.authService.currentUser?.uid;
    if (!uid) return;
    this.commentText = '';
    this.isSending = true;
    try {
      await this.postService.addComment({
        postId: this.post.id,
        authorId: uid,
        text,
        likesCount: 0,
      });
    } finally {
      this.isSending = false;
    }
  }

  formatTime(ts: any): string {
    const d = ts?.toDate ? ts.toDate() : new Date(ts);
    const diff = Date.now() - d.getTime();
    if (diff < 3600000) return Math.floor(diff / 60000) + 'm';
    if (diff < 86400000) return Math.floor(diff / 3600000) + 'h';
    return Math.floor(diff / 86400000) + 'd';
  }
}
