import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  addDoc,
  updateDoc,
  query,
  where,
  orderBy,
  limit,
  getDocs,
  collectionData,
  serverTimestamp,
  writeBatch,
} from '@angular/fire/firestore';
import { PushNotifications, Token, ActionPerformed, PushNotificationSchema } from '@capacitor/push-notifications';
import { Capacitor } from '@capacitor/core';
import { Observable } from 'rxjs';
import { Notification, NotificationType } from '../../models';

@Injectable({
  providedIn: 'root',
})
export class NotificationService {
  private firestore = inject(Firestore);

  // ─── Init Push Notifications ──────────────────────────────────────────────────

  async initPushNotifications(userId: string): Promise<void> {
    if (!Capacitor.isNativePlatform()) return;

    const permission = await PushNotifications.requestPermissions();
    if (permission.receive !== 'granted') return;

    await PushNotifications.register();

    PushNotifications.addListener('registration', async (token: Token) => {
      await this.saveFcmToken(userId, token.value);
    });

    PushNotifications.addListener(
      'pushNotificationReceived',
      (notification: PushNotificationSchema) => {
        console.log('Push received:', notification);
      }
    );

    PushNotifications.addListener(
      'pushNotificationActionPerformed',
      (action: ActionPerformed) => {
        this.handleNotificationAction(action);
      }
    );
  }

  private async saveFcmToken(userId: string, token: string): Promise<void> {
    const { arrayUnion } = await import('@angular/fire/firestore');
    const userRef = doc(this.firestore, `users/${userId}`);
    await updateDoc(userRef, { fcmTokens: arrayUnion(token) });
  }

  private handleNotificationAction(action: ActionPerformed): void {
    const data = action.notification.data;
    // Navigation handled by the app component
    console.log('Notification action:', data);
  }

  // ─── Firestore Notifications ──────────────────────────────────────────────────

  getUnreadNotifications(userId: string): Observable<Notification[]> {
    const ref = collection(this.firestore, 'notifications');
    const q = query(
      ref,
      where('recipientId', '==', userId),
      where('isRead', '==', false),
      orderBy('createdAt', 'desc'),
      limit(50)
    );
    return collectionData(q, { idField: 'id' }) as Observable<Notification[]>;
  }

  getAllNotifications(userId: string): Observable<Notification[]> {
    const ref = collection(this.firestore, 'notifications');
    const q = query(
      ref,
      where('recipientId', '==', userId),
      orderBy('createdAt', 'desc'),
      limit(50)
    );
    return collectionData(q, { idField: 'id' }) as Observable<Notification[]>;
  }

  async markAsRead(notificationId: string): Promise<void> {
    const ref = doc(this.firestore, `notifications/${notificationId}`);
    await updateDoc(ref, { isRead: true });
  }

  async markAllAsRead(userId: string): Promise<void> {
    const ref = collection(this.firestore, 'notifications');
    const q = query(
      ref,
      where('recipientId', '==', userId),
      where('isRead', '==', false)
    );
    const snap = await getDocs(q);
    const batch = writeBatch(this.firestore);
    snap.docs.forEach((d) => batch.update(d.ref, { isRead: true }));
    await batch.commit();
  }

  async createNotification(
    notification: Omit<Notification, 'id' | 'createdAt'>
  ): Promise<void> {
    const ref = collection(this.firestore, 'notifications');
    await addDoc(ref, {
      ...notification,
      createdAt: serverTimestamp(),
    });
  }

  async getUnreadCount(userId: string): Promise<number> {
    const ref = collection(this.firestore, 'notifications');
    const q = query(
      ref,
      where('recipientId', '==', userId),
      where('isRead', '==', false)
    );
    const snap = await getDocs(q);
    return snap.size;
  }
}
