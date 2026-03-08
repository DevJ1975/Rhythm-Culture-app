import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute } from '@angular/router';
import {
  IonHeader, IonToolbar, IonContent, IonButton, IonIcon,
  IonButtons, IonRefresher, IonRefresherContent, IonSkeletonText,
  IonGrid, IonRow, IonCol, IonSegment, IonSegmentButton, IonLabel,
  RefresherEventDetail,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import {
  settingsOutline, createOutline, shareOutline,
  gridOutline, filmOutline, personAddOutline, checkmarkOutline,
  ellipsisVertical, chevronBackOutline,
} from 'ionicons/icons';
import { UserProfile, Post } from '../../models';
import { AuthService } from '../../core/services/auth.service';
import { UserService } from '../../core/services/user.service';
import { PostService } from '../../core/services/post.service';
import { SpecialtyBadgeComponent } from '../../shared/components/specialty-badge/specialty-badge.component';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.page.html',
  styleUrls: ['./profile.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterModule,
    IonHeader, IonToolbar, IonContent, IonButton, IonIcon,
    IonButtons, IonRefresher, IonRefresherContent, IonSkeletonText,
    IonGrid, IonRow, IonCol, IonSegment, IonSegmentButton, IonLabel,
    SpecialtyBadgeComponent,
  ],
})
export class ProfilePage implements OnInit {
  private authService = inject(AuthService);
  private userService = inject(UserService);
  private postService = inject(PostService);
  private route = inject(ActivatedRoute);

  profile: UserProfile | null = null;
  posts: Post[] = [];
  isLoading = true;
  isOwnProfile = false;
  isFollowing = false;
  activeSegment = 'posts';
  profileUid = '';

  constructor() {
    addIcons({
      settingsOutline, createOutline, shareOutline, gridOutline, filmOutline,
      personAddOutline, checkmarkOutline, ellipsisVertical, chevronBackOutline,
    });
  }

  ngOnInit(): void {
    const uidParam = this.route.snapshot.paramMap.get('uid');
    const currentUid = this.authService.currentUser?.uid ?? '';
    this.profileUid = uidParam ?? currentUid;
    this.isOwnProfile = this.profileUid === currentUid;
    this.loadProfile();
  }

  async loadProfile(): Promise<void> {
    this.isLoading = true;
    try {
      this.profile = await this.userService.getUserProfileOnce(this.profileUid);
      if (!this.isOwnProfile) {
        this.isFollowing = await this.userService.isFollowing(
          this.authService.currentUser?.uid ?? '',
          this.profileUid
        );
      }
      const result = await this.postService.getUserPosts(this.profileUid);
      this.posts = result.posts;
    } finally {
      this.isLoading = false;
    }
  }

  async toggleFollow(): Promise<void> {
    const currentUid = this.authService.currentUser?.uid;
    if (!currentUid || !this.profile) return;
    if (this.isFollowing) {
      await this.userService.unfollowUser(currentUid, this.profileUid);
      this.profile.followersCount--;
      this.isFollowing = false;
    } else {
      await this.userService.followUser(currentUid, this.profileUid);
      this.profile.followersCount++;
      this.isFollowing = true;
    }
  }

  async onRefresh(event: CustomEvent<RefresherEventDetail>): Promise<void> {
    await this.loadProfile();
    event.detail.complete();
  }

  formatCount(n: number): string {
    if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M';
    if (n >= 1000) return (n / 1000).toFixed(1) + 'K';
    return n.toString();
  }
}
