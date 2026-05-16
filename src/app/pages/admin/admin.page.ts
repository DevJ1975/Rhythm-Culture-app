import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonItem,
  IonInput,
  IonLabel,
  IonButton,
  IonList,
  IonNote,
  IonSegment,
  IonSegmentButton,
} from '@ionic/angular/standalone';
import { AdminService } from '../../core/services/admin.service';

@Component({
  selector: 'app-admin',
  templateUrl: './admin.page.html',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterModule,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonItem,
    IonInput,
    IonLabel,
    IonButton,
    IonList,
    IonNote,
    IonSegment,
    IonSegmentButton,
  ],
})
export class AdminPage {
  private admin = inject(AdminService);

  tab: 'verify' | 'admins' = 'verify';
  uid = '';
  busy = false;
  message = '';

  async verify(verified: boolean): Promise<void> {
    if (!this.uid) return;
    this.busy = true;
    try {
      await this.admin.setUserVerified(this.uid, verified);
      this.message = verified ? 'User verified' : 'Verification removed';
    } catch (e: any) {
      this.message = e?.message || 'Failed';
    } finally {
      this.busy = false;
    }
  }

  async grant(): Promise<void> {
    if (!this.uid) return;
    this.busy = true;
    try {
      await this.admin.grantAdmin(this.uid);
      this.message = 'Admin granted';
    } catch (e: any) {
      this.message = e?.message || 'Failed';
    } finally {
      this.busy = false;
    }
  }

  async revoke(): Promise<void> {
    if (!this.uid) return;
    this.busy = true;
    try {
      await this.admin.revokeAdmin(this.uid);
      this.message = 'Admin revoked';
    } catch (e: any) {
      this.message = e?.message || 'Failed';
    } finally {
      this.busy = false;
    }
  }
}
