import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonSearchbar,
  IonSegment, IonSegmentButton, IonLabel, IonList, IonItem,
  IonAvatar, IonButton, IonIcon, IonChip, IonSkeletonText,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { searchOutline, filterOutline, trophyOutline, chevronForwardOutline } from 'ionicons/icons';
import { UserProfile, ArtistSpecialty } from '../../models';
import { UserService } from '../../core/services/user.service';
import { CollaborationService } from '../../core/services/collaboration.service';
import { MockDataService } from '../../core/services/mock-data.service';
import { Collaboration } from '../../models';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-discover',
  templateUrl: './discover.page.html',
  styleUrls: ['./discover.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterModule, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonSearchbar,
    IonSegment, IonSegmentButton, IonLabel, IonList, IonItem,
    IonAvatar, IonButton, IonIcon, IonChip, IonSkeletonText,
  ],
})
export class DiscoverPage implements OnInit {
  private userService = inject(UserService);
  private collabService = inject(CollaborationService);
  private mockData = inject(MockDataService);

  activeSegment = 'artists';
  searchQuery = '';
  isLoading = false;
  artists: UserProfile[] = [];
  collaborations: Collaboration[] = [];

  specialtyFilters: ArtistSpecialty[] = [
    'Dance', 'Music', 'Vocals', 'Choreography', 'DJ', 'Production', 'Rap',
  ];
  selectedSpecialty: ArtistSpecialty | null = null;

  constructor() {
    addIcons({ searchOutline, filterOutline, trophyOutline, chevronForwardOutline });
  }

  ngOnInit(): void {
    this.loadArtists();
    this.loadCollaborations();
  }

  async loadArtists(): Promise<void> {
    this.isLoading = true;
    try {
      if (!environment.production) {
        const all = this.mockData.getAllProfiles();
        this.artists = this.selectedSpecialty
          ? all.filter(u => u.specialties.includes(this.selectedSpecialty!))
          : all;
        return;
      }
      const result = this.selectedSpecialty
        ? await this.userService.getUsersBySpecialty(this.selectedSpecialty)
        : await this.userService.getUsersBySpecialty('Dance');
      this.artists = result.users;
    } finally {
      this.isLoading = false;
    }
  }

  async loadCollaborations(): Promise<void> {
    if (!environment.production) {
      const all = this.mockData.getCollaborations();
      this.collaborations = this.selectedSpecialty
        ? all.filter(c => c.skills.includes(this.selectedSpecialty!))
        : all;
      return;
    }
    const result = await this.collabService.getCollaborations(
      this.selectedSpecialty ? { skill: this.selectedSpecialty } : {}
    );
    this.collaborations = result.collabs;
  }

  async onSpecialtyFilter(specialty: ArtistSpecialty): Promise<void> {
    this.selectedSpecialty = this.selectedSpecialty === specialty ? null : specialty;
    await this.loadArtists();
    await this.loadCollaborations();
  }

  async onSearch(event: any): Promise<void> {
    const query = (event.detail.value ?? '').trim().toLowerCase();
    if (!query) {
      await this.loadArtists();
      return;
    }
    if (!environment.production) {
      this.artists = this.mockData.getAllProfiles().filter(u =>
        u.displayName.toLowerCase().includes(query) ||
        (u.artistName ?? '').toLowerCase().includes(query) ||
        u.specialties.some(s => s.toLowerCase().includes(query))
      );
      return;
    }
    this.isLoading = true;
    this.artists = await this.userService.searchUsers(query);
    this.isLoading = false;
  }
}
