import { Component, OnDestroy, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonSearchbar,
  IonSegment,
  IonSegmentButton,
  IonLabel,
  IonList,
  IonItem,
  IonAvatar,
  IonIcon,
  IonSpinner,
  IonBackButton,
  IonButtons,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { searchOutline, trendingUpOutline } from 'ionicons/icons';
import { Subject, debounceTime, distinctUntilChanged, takeUntil } from 'rxjs';
import { SearchService, SearchResults } from '../../core/services/search.service';

type SearchTab = 'all' | 'users' | 'posts' | 'events' | 'courses' | 'collaborations';

@Component({
  selector: 'app-search',
  templateUrl: './search.page.html',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterModule,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonSearchbar,
    IonSegment,
    IonSegmentButton,
    IonLabel,
    IonList,
    IonItem,
    IonAvatar,
    IonIcon,
    IonSpinner,
    IonBackButton,
    IonButtons,
  ],
})
export class SearchPage implements OnDestroy {
  private search = inject(SearchService);
  private destroy$ = new Subject<void>();
  private input$ = new Subject<string>();

  query = '';
  tab: SearchTab = 'all';
  loading = false;
  results: SearchResults = {
    users: [],
    posts: [],
    events: [],
    courses: [],
    collaborations: [],
    hashtags: [],
  };

  constructor() {
    addIcons({ searchOutline, trendingUpOutline });
    this.input$
      .pipe(debounceTime(250), distinctUntilChanged(), takeUntil(this.destroy$))
      .subscribe((value) => this.run(value));
  }

  onInput(ev: CustomEvent): void {
    const value = (ev.detail as { value?: string }).value || '';
    this.query = value;
    this.input$.next(value);
  }

  async run(value: string): Promise<void> {
    if (!value.trim()) {
      this.results = {
        users: [],
        posts: [],
        events: [],
        courses: [],
        collaborations: [],
        hashtags: [],
      };
      return;
    }
    this.loading = true;
    try {
      this.results = await this.search.searchAll(value);
    } finally {
      this.loading = false;
    }
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
