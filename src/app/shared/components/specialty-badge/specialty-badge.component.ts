import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ArtistSpecialty } from '../../../models';

const SPECIALTY_COLORS: Record<string, string> = {
  Dance: 'bg-purple-500 bg-opacity-20 text-purple-300 border-purple-500 border-opacity-30',
  Music: 'bg-blue-500 bg-opacity-20 text-blue-300 border-blue-500 border-opacity-30',
  Vocals: 'bg-pink-500 bg-opacity-20 text-pink-300 border-pink-500 border-opacity-30',
  Choreography: 'bg-indigo-500 bg-opacity-20 text-indigo-300 border-indigo-500 border-opacity-30',
  DJ: 'bg-orange-500 bg-opacity-20 text-orange-300 border-orange-500 border-opacity-30',
  Production: 'bg-green-500 bg-opacity-20 text-green-300 border-green-500 border-opacity-30',
  Acting: 'bg-yellow-500 bg-opacity-20 text-yellow-300 border-yellow-500 border-opacity-30',
  Rap: 'bg-red-500 bg-opacity-20 text-red-300 border-red-500 border-opacity-30',
  Other: 'bg-gray-500 bg-opacity-20 text-gray-300 border-gray-500 border-opacity-30',
};

@Component({
  selector: 'app-specialty-badge',
  template: `
    <span
      [class]="'inline-flex items-center px-3 py-1 rounded-full text-xs font-medium border ' + colorClass"
    >{{ specialty }}</span>
  `,
  standalone: true,
  imports: [CommonModule],
})
export class SpecialtyBadgeComponent {
  @Input() specialty!: ArtistSpecialty | string;

  get colorClass(): string {
    return SPECIALTY_COLORS[this.specialty] ?? SPECIALTY_COLORS['Other'];
  }
}
