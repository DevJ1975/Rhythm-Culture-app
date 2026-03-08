import { Component, Input, Output, EventEmitter, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  IonCard, IonCardContent, IonButton, IonIcon,
  IonAvatar, IonChip, IonLabel, IonItem, IonSkeletonText,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  heartOutline, heart, chatbubbleOutline, shareSocialOutline,
  ellipsisHorizontal, playCircle, musicalNoteOutline,
} from 'ionicons/icons';
import { Post } from '../../../models';
import { AuthService } from '../../../core/services/auth.service';
import { PostService } from '../../../core/services/post.service';

@Component({
  selector: 'app-post-card',
  templateUrl: './post-card.component.html',
  styleUrls: ['./post-card.component.scss'],
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    IonCard, IonCardContent, IonButton, IonIcon,
    IonAvatar, IonChip, IonLabel, IonItem, IonSkeletonText,
  ],
})
export class PostCardComponent implements OnInit {
  @Input() post!: Post;
  @Input() showActions = true;
  @Output() commentClicked = new EventEmitter<Post>();
  @Output() shareClicked = new EventEmitter<Post>();

  private authService = inject(AuthService);
  private postService = inject(PostService);

  isLiked = false;
  isLoading = false;

  constructor() {
    addIcons({
      heartOutline, heart, chatbubbleOutline,
      shareSocialOutline, ellipsisHorizontal, playCircle, musicalNoteOutline,
    });
  }

  ngOnInit(): void {
    const uid = this.authService.currentUser?.uid;
    if (uid) {
      this.postService.hasLiked(this.post.id, uid).then((liked) => {
        this.isLiked = liked;
      });
    }
  }

  async toggleLike(): Promise<void> {
    const uid = this.authService.currentUser?.uid;
    if (!uid || this.isLoading) return;

    this.isLoading = true;
    try {
      if (this.isLiked) {
        await this.postService.unlikePost(this.post.id, uid);
        this.post.likesCount--;
        this.isLiked = false;
      } else {
        await this.postService.likePost(this.post.id, uid);
        this.post.likesCount++;
        this.isLiked = true;
      }
    } finally {
      this.isLoading = false;
    }
  }

  onComment(): void {
    this.commentClicked.emit(this.post);
  }

  onShare(): void {
    this.shareClicked.emit(this.post);
  }

  getTimeSince(timestamp: any): string {
    const date = timestamp?.toDate ? timestamp.toDate() : new Date(timestamp);
    const seconds = Math.floor((Date.now() - date.getTime()) / 1000);
    if (seconds < 60) return 'just now';
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h`;
    if (seconds < 604800) return `${Math.floor(seconds / 86400)}d`;
    return date.toLocaleDateString();
  }

  formatCount(count: number): string {
    if (count >= 1000000) return (count / 1000000).toFixed(1) + 'M';
    if (count >= 1000) return (count / 1000).toFixed(1) + 'K';
    return count.toString();
  }
}
