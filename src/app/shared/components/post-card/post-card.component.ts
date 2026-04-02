import { Component, Input, Output, EventEmitter, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { IonIcon } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  heartOutline, heart, chatbubbleOutline, paperPlaneOutline,
  ellipsisHorizontal, play, musicalNoteOutline, checkmarkOutline,
  bookmarkOutline,
} from 'ionicons/icons';
import { Post } from '../../../models';
import { AuthService } from '../../../core/services/auth.service';
import { PostService } from '../../../core/services/post.service';

@Component({
  selector: 'app-post-card',
  templateUrl: './post-card.component.html',
  styleUrls: ['./post-card.component.scss'],
  standalone: true,
  imports: [CommonModule, RouterModule, IonIcon],
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
  captionExpanded = false;

  // Randomised-but-stable waveform bars for audio posts
  readonly audioBars = Array.from({ length: 28 }, (_, i) =>
    8 + Math.round(Math.abs(Math.sin(i * 0.9)) * 20)
  );

  constructor() {
    addIcons({
      heartOutline, heart, chatbubbleOutline, paperPlaneOutline,
      ellipsisHorizontal, play, musicalNoteOutline, checkmarkOutline,
      bookmarkOutline,
    });
  }

  ngOnInit(): void {
    const uid = this.authService.currentUser?.uid;
    if (uid) {
      this.postService.hasLiked(this.post.id, uid).then((liked) => {
        this.isLiked = liked;
      }).catch(() => {});
    }
  }

  async toggleLike(): Promise<void> {
    const uid = this.authService.currentUser?.uid;
    if (this.isLoading) return;

    // Optimistic update works even without auth in dev
    this.isLiked = !this.isLiked;
    this.post.likesCount += this.isLiked ? 1 : -1;

    if (!uid) return;
    this.isLoading = true;
    try {
      if (this.isLiked) {
        await this.postService.likePost(this.post.id, uid);
      } else {
        await this.postService.unlikePost(this.post.id, uid);
      }
    } catch {
      // Revert on error
      this.isLiked = !this.isLiked;
      this.post.likesCount += this.isLiked ? 1 : -1;
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

  onOptions(event: Event): void {
    event.stopPropagation();
  }

  getTimeSince(timestamp: any): string {
    const date = timestamp?.toDate ? timestamp.toDate() : new Date(timestamp);
    const seconds = Math.floor((Date.now() - date.getTime()) / 1000);
    if (seconds < 60) return 'just now';
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    if (seconds < 604800) return `${Math.floor(seconds / 86400)}d ago`;
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  }

  formatCount(count: number): string {
    if (count >= 1_000_000) return (count / 1_000_000).toFixed(1) + 'M';
    if (count >= 1_000) return (count / 1_000).toFixed(1) + 'K';
    return count.toString();
  }

  formatDuration(seconds?: number): string {
    if (!seconds) return '';
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m}:${s.toString().padStart(2, '0')}`;
  }
}
