import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonRefresher, IonRefresherContent, IonInfiniteScroll,
  IonInfiniteScrollContent, IonSkeletonText, IonButtons, IonBadge,
  IonSegment, IonSegmentButton, IonLabel,
  RefresherEventDetail, InfiniteScrollCustomEvent,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { notificationsOutline, chatbubblesOutline, addOutline } from 'ionicons/icons';
import { Post } from '../../models';
import { PostService } from '../../core/services/post.service';
import { AuthService } from '../../core/services/auth.service';
import { UserService } from '../../core/services/user.service';
import { RecommendationService } from '../../core/services/recommendation.service';
import { MockDataService } from '../../core/services/mock-data.service';
import { PostCardComponent } from '../../shared/components/post-card/post-card.component';
import { EmptyStateComponent } from '../../shared/components/empty-state/empty-state.component';
import { StoriesStripComponent } from '../../shared/components/stories-strip/stories-strip.component';
import { MockStory } from '../../core/services/mock-data.service';
import { QueryDocumentSnapshot } from '@angular/fire/firestore';
import { environment } from '../../../environments/environment';

type FeedMode = 'following' | 'foryou';

@Component({
  selector: 'app-feed',
  templateUrl: './feed.page.html',
  styleUrls: ['./feed.page.scss'],
  standalone: true,
  imports: [
    CommonModule, FormsModule, RouterModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonRefresher, IonRefresherContent, IonInfiniteScroll,
    IonInfiniteScrollContent, IonSkeletonText, IonButtons, IonBadge,
    IonSegment, IonSegmentButton, IonLabel,
    PostCardComponent, EmptyStateComponent, StoriesStripComponent,
  ],
})
export class FeedPage implements OnInit {
  private postService = inject(PostService);
  private authService = inject(AuthService);
  private userService = inject(UserService);
  private recommendation = inject(RecommendationService);
  private mockData = inject(MockDataService);

  mode: FeedMode = 'following';
  posts: Post[] = [];
  stories: MockStory[] = [];
  isLoading = true;
  hasMore = true;
  private lastDoc: QueryDocumentSnapshot | null = null;

  constructor() {
    addIcons({ notificationsOutline, chatbubblesOutline, addOutline });
  }

  ngOnInit(): void {
    this.loadPosts();
    if (!environment.production) {
      this.stories = this.mockData.getStories();
    }
  }

  async onModeChange(): Promise<void> {
    this.posts = [];
    this.lastDoc = null;
    this.hasMore = true;
    await this.loadPosts(true);
  }

  async loadPosts(reset = false): Promise<void> {
    if (reset) {
      this.lastDoc = null;
      this.hasMore = true;
    }
    this.isLoading = true;
    try {
      if (!environment.production) {
        this.posts = this.mockData.getFeedPosts();
        this.hasMore = false;
        return;
      }
      if (this.mode === 'foryou') {
        const uid = this.authService.currentUser?.uid;
        if (!uid) {
          this.posts = [];
          this.hasMore = false;
          return;
        }
        const profile = await this.userService.getUserProfileOnce(uid);
        if (!profile) {
          this.posts = [];
          this.hasMore = false;
          return;
        }
        // Recommendation feed is a single-shot ranked list — no infinite scroll for now.
        this.posts = await this.recommendation.forYouFeed(profile, 30);
        this.hasMore = false;
        return;
      }
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
