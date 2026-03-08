import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonRefresher, IonRefresherContent, IonInfiniteScroll,
  IonInfiniteScrollContent, IonSkeletonText, IonButtons, IonBadge,
  RefresherEventDetail, InfiniteScrollCustomEvent,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { notificationsOutline, chatbubblesOutline, addOutline } from 'ionicons/icons';
import { Post } from '../../models';
import { PostService } from '../../core/services/post.service';
import { AuthService } from '../../core/services/auth.service';
import { PostCardComponent } from '../../shared/components/post-card/post-card.component';
import { EmptyStateComponent } from '../../shared/components/empty-state/empty-state.component';
import { QueryDocumentSnapshot } from '@angular/fire/firestore';

@Component({
  selector: 'app-feed',
  templateUrl: './feed.page.html',
  styleUrls: ['./feed.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonRefresher, IonRefresherContent, IonInfiniteScroll,
    IonInfiniteScrollContent, IonSkeletonText, IonButtons, IonBadge,
    PostCardComponent, EmptyStateComponent,
  ],
})
export class FeedPage implements OnInit {
  private postService = inject(PostService);
  private authService = inject(AuthService);

  posts: Post[] = [];
  isLoading = true;
  hasMore = true;
  private lastDoc: QueryDocumentSnapshot | null = null;

  constructor() {
    addIcons({ notificationsOutline, chatbubblesOutline, addOutline });
  }

  ngOnInit(): void {
    this.loadPosts();
  }

  async loadPosts(reset = false): Promise<void> {
    if (reset) {
      this.lastDoc = null;
      this.hasMore = true;
    }
    this.isLoading = true;
    try {
      const result = await this.postService.getFeedPosts(10, this.lastDoc ?? undefined);
      if (reset) {
        this.posts = result.posts;
      } else {
        this.posts = [...this.posts, ...result.posts];
      }
      this.lastDoc = result.lastDoc;
      this.hasMore = result.posts.length === 10;
    } finally {
      this.isLoading = false;
    }
  }

  async onRefresh(event: CustomEvent<RefresherEventDetail>): Promise<void> {
    await this.loadPosts(true);
    event.detail.complete();
  }

  async onInfiniteScroll(event: InfiniteScrollCustomEvent): Promise<void> {
    if (!this.hasMore) {
      await event.target.complete();
      return;
    }
    await this.loadPosts();
    await event.target.complete();
  }

  trackByPostId(_: number, post: Post): string {
    return post.id;
  }
}
