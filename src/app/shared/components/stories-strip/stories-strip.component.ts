import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { IonIcon } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { addOutline } from 'ionicons/icons';
import { MockStory } from '../../../core/services/mock-data.service';

@Component({
  selector: 'app-stories-strip',
  templateUrl: './stories-strip.component.html',
  styleUrls: ['./stories-strip.component.scss'],
  standalone: true,
  imports: [CommonModule, RouterModule, IonIcon],
})
export class StoriesStripComponent {
  @Input() stories: MockStory[] = [];

  constructor() {
    addIcons({ addOutline });
  }
}
