import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  addDoc,
  getDocs,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  collectionData,
  docData,
  serverTimestamp,
  increment,
  Timestamp,
  QueryDocumentSnapshot,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { Event, EventRegistration } from '../../models';

@Injectable({
  providedIn: 'root',
})
export class EventService {
  private firestore = inject(Firestore);

  // ─── List Events ──────────────────────────────────────────────────────────────

  async getUpcomingEvents(
    filters: { category?: string; city?: string } = {},
    pageLimit = 10,
    lastDoc?: QueryDocumentSnapshot
  ): Promise<{ events: Event[]; lastDoc: QueryDocumentSnapshot | null }> {
    const ref = collection(this.firestore, 'events');
    const now = Timestamp.now();
    let q = query(
      ref,
      where('isPublished', '==', true),
      where('isCancelled', '==', false),
      where('eventDate', '>=', now),
      orderBy('eventDate', 'asc'),
      limit(pageLimit)
    );

    if (filters.category) {
      q = query(q, where('category', '==', filters.category));
    }
    if (lastDoc) {
      q = query(q, startAfter(lastDoc));
    }

    const snap = await getDocs(q);
    return {
      events: snap.docs.map((d) => ({ ...d.data(), id: d.id }) as Event),
      lastDoc: snap.docs.length > 0 ? snap.docs[snap.docs.length - 1] : null,
    };
  }

  getEventById(id: string): Observable<Event | undefined> {
    const ref = doc(this.firestore, `events/${id}`);
    return docData(ref, { idField: 'id' }) as Observable<Event | undefined>;
  }

  getUserEvents(userId: string): Observable<Event[]> {
    const ref = collection(this.firestore, 'events');
    const q = query(
      ref,
      where('organizerId', '==', userId),
      orderBy('eventDate', 'desc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<Event[]>;
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────────

  async createEvent(
    event: Omit<Event, 'id' | 'createdAt' | 'updatedAt' | 'currentAttendees'>
  ): Promise<string> {
    const ref = collection(this.firestore, 'events');
    const docRef = await addDoc(ref, {
      ...event,
      currentAttendees: 0,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    return docRef.id;
  }

  async updateEvent(id: string, updates: Partial<Event>): Promise<void> {
    const ref = doc(this.firestore, `events/${id}`);
    await updateDoc(ref, { ...updates, updatedAt: serverTimestamp() });
  }

  async deleteEvent(id: string): Promise<void> {
    const ref = doc(this.firestore, `events/${id}`);
    await deleteDoc(ref);
  }

  // ─── Registration ─────────────────────────────────────────────────────────────

  async registerForEvent(eventId: string, userId: string): Promise<void> {
    const regRef = collection(this.firestore, 'event_registrations');
    const eventRef = doc(this.firestore, `events/${eventId}`);

    await addDoc(regRef, {
      eventId,
      userId,
      status: 'registered',
      paymentStatus: 'pending',
      registeredAt: serverTimestamp(),
    } as Omit<EventRegistration, 'id'>);

    await updateDoc(eventRef, { currentAttendees: increment(1) });
  }

  async cancelRegistration(registrationId: string, eventId: string): Promise<void> {
    const regRef = doc(this.firestore, `event_registrations/${registrationId}`);
    const eventRef = doc(this.firestore, `events/${eventId}`);

    await updateDoc(regRef, { status: 'cancelled' });
    await updateDoc(eventRef, { currentAttendees: increment(-1) });
  }

  async getUserRegistrations(userId: string): Promise<EventRegistration[]> {
    const ref = collection(this.firestore, 'event_registrations');
    const q = query(
      ref,
      where('userId', '==', userId),
      where('status', '==', 'registered')
    );
    const snap = await getDocs(q);
    return snap.docs.map((d) => ({ ...d.data(), id: d.id }) as EventRegistration);
  }
}
