import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { IonAvatar, IonIcon } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { checkmarkCircle } from 'ionicons/icons';
import { UserSummary } from '../../../models';

@Component({
  selector: 'app-user-avatar',
  templateUrl: './user-avatar.component.html',
  styleUrls: ['./user-avatar.component.scss'],
  standalone: true,
  imports: [CommonModule, RouterModule, IonAvatar, IonIcon],
})
export class UserAvatarComponent {
  @Input() user!: UserSummary | { uid: string; displayName: string; photoURL?: string; isVerified?: boolean };
  @Input() size: 'xs' | 'sm' | 'md' | 'lg' | 'xl' = 'md';
  @Input() showVerified = true;
  @Input() navigable = false;
  @Input() showName = false;
  @Input() showSpecialty = false;

  constructor() {
    addIcons({ checkmarkCircle });
  }

  get sizeClasses(): string {
    const map = {
      xs: 'w-6 h-6',
      sm: 'w-8 h-8',
      md: 'w-10 h-10',
      lg: 'w-14 h-14',
      xl: 'w-20 h-20',
    };
    return map[this.size];
  }

  get verifiedIconSize(): string {
    const map = { xs: '10px', sm: '12px', md: '14px', lg: '18px', xl: '22px' };
    return map[this.size];
  }
}
