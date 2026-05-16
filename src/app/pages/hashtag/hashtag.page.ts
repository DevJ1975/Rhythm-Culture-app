import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonBackButton,
  IonButtons,
  IonSpinner,
} from '@ionic/angular/standalone';
import { PostCardComponent } from '../../shared/components/post-card/post-card.component';
import { SearchService } from '../../core/services/search.service';
import { Post } from '../../models';

@Component({
  selector: 'app-hashtag',
  templateUrl: './hashtag.page.html',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    PostCardComponent,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonBackButton,
    IonButtons,
    IonSpinner,
  ],
})
export class HashtagPage implements OnInit {
  private route = inject(ActivatedRoute);
  private search = inject(SearchService);

  tag = '';
  posts: Post[] = [];
  loading = false;

  async ngOnInit(): Promise<void> {
    this.tag = (this.route.snapshot.paramMap.get('tag') || '').toLowerCase();
    this.loading = true;
    try {
      this.posts = await this.search.searchPostsByTag(this.tag, 30);
    } finally {
      this.loading = false;
    }
  }
}
