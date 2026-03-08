import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
  IonSegment, IonSegmentButton, IonLabel, IonChip, IonFab, IonFabButton,
  IonSkeletonText,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { addOutline, filterOutline, locationOutline, peopleOutline } from 'ionicons/icons';
import { Collaboration, ArtistSpecialty } from '../../models';
import { CollaborationService } from '../../core/services/collaboration.service';

@Component({
  selector: 'app-collaboration',
  templateUrl: './collaboration.page.html',
  styleUrls: ['./collaboration.page.scss'],
  standalone: true,
  imports: [
    CommonModule, RouterModule, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon,
    IonSegment, IonSegmentButton, IonLabel, IonChip, IonFab, IonFabButton, IonSkeletonText,
  ],
})
export class CollaborationPage implements OnInit {
  private collabService = inject(CollaborationService);

  collaborations: Collaboration[] = [];
  isLoading = true;
  selectedSkill: ArtistSpecialty | null = null;
  isRemoteFilter: boolean | null = null;

  skills: ArtistSpecialty[] = [
    'Dance', 'Music', 'Vocals', 'Choreography', 'DJ', 'Production', 'Rap', 'Acting',
  ];

  constructor() {
    addIcons({ addOutline, filterOutline, locationOutline, peopleOutline });
  }

  ngOnInit(): void {
    this.loadCollabs();
  }

  async loadCollabs(): Promise<void> {
    this.isLoading = true;
    const filters: any = {};
    if (this.selectedSkill) filters.skill = this.selectedSkill;
    if (this.isRemoteFilter !== null) filters.isRemote = this.isRemoteFilter;
    const result = await this.collabService.getCollaborations(filters);
    this.collaborations = result.collabs;
    this.isLoading = false;
  }

  async filterBySkill(skill: ArtistSpecialty): Promise<void> {
    this.selectedSkill = this.selectedSkill === skill ? null : skill;
    await this.loadCollabs();
  }

  async filterRemote(val: boolean | null): Promise<void> {
    this.isRemoteFilter = this.isRemoteFilter === val ? null : val;
    await this.loadCollabs();
  }
}
