import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonList,
  IonItem,
  IonLabel,
  IonBadge,
  IonButton,
  IonButtons,
  IonBackButton,
  IonSegment,
  IonSegmentButton,
  IonNote,
  IonSpinner,
} from '@ionic/angular/standalone';
import {
  Firestore,
  collection,
  query,
  where,
  orderBy,
  limit,
  collectionData,
} from '@angular/fire/firestore';
import { Functions, httpsCallable } from '@angular/fire/functions';
import { Observable } from 'rxjs';
import { Report, ReportStatus } from '../../../models';

@Component({
  selector: 'app-moderation-queue',
  templateUrl: './moderation-queue.page.html',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterModule,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonList,
    IonItem,
    IonLabel,
    IonBadge,
    IonButton,
    IonButtons,
    IonBackButton,
    IonSegment,
    IonSegmentButton,
    IonNote,
    IonSpinner,
  ],
})
export class ModerationQueuePage implements OnInit {
  private firestore = inject(Firestore);
  private functions = inject(Functions);

  status: ReportStatus = 'open';
  reports$!: Observable<Report[]>;
  busyId: string | null = null;
  message = '';

  ngOnInit(): void {
    this.refresh();
  }

  refresh(): void {
    const ref = collection(this.firestore, 'reports');
    const q = query(
      ref,
      where('status', '==', this.status),
      orderBy('createdAt', 'desc'),
      limit(50)
    );
    this.reports$ = collectionData(q, { idField: 'id' }) as Observable<Report[]>;
  }

  onStatusChange(): void {
    this.refresh();
  }

  async resolve(report: Report, action: 'approve' | 'dismiss'): Promise<void> {
    this.busyId = report.id;
    try {
      const fn = httpsCallable(this.functions, 'resolveReport');
      await fn({ reportId: report.id, action });
      this.message = action === 'approve' ? 'Report actioned' : 'Report dismissed';
      setTimeout(() => (this.message = ''), 2500);
    } catch (e: any) {
      this.message = e?.message || 'Failed';
    } finally {
      this.busyId = null;
    }
  }

  badgeColor(status: ReportStatus): string {
    switch (status) {
      case 'open':
        return 'warning';
      case 'reviewing':
        return 'primary';
      case 'actioned':
        return 'danger';
      case 'dismissed':
        return 'medium';
    }
  }

  targetLink(report: Report): string | null {
    switch (report.targetType) {
      case 'post':
        return `/post/${report.targetId}`;
      case 'user':
        return `/profile/${report.targetId}`;
      case 'event':
        return `/events/${report.targetId}`;
      case 'course':
        return `/masterclass/${report.targetId}`;
      case 'comment':
      case 'message':
        return null;
    }
  }
}
