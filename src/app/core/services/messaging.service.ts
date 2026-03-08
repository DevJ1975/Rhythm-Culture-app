import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  addDoc,
  getDoc,
  getDocs,
  updateDoc,
  query,
  where,
  orderBy,
  limit,
  collectionData,
  serverTimestamp,
  increment,
  setDoc,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { Conversation, Message } from '../../models';

@Injectable({
  providedIn: 'root',
})
export class MessagingService {
  private firestore = inject(Firestore);

  // ─── Conversations ────────────────────────────────────────────────────────────

  getUserConversations(userId: string): Observable<Conversation[]> {
    const ref = collection(this.firestore, 'conversations');
    const q = query(
      ref,
      where('participantIds', 'array-contains', userId),
      orderBy('updatedAt', 'desc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<Conversation[]>;
  }

  async getOrCreateConversation(
    userId1: string,
    userId2: string
  ): Promise<string> {
    // Conversation ID is deterministic: sorted user IDs joined
    const ids = [userId1, userId2].sort();
    const conversationId = ids.join('_');
    const ref = doc(this.firestore, `conversations/${conversationId}`);
    const snap = await getDoc(ref);

    if (!snap.exists()) {
      const now = serverTimestamp();
      await setDoc(ref, {
        id: conversationId,
        participantIds: ids,
        unreadCounts: { [userId1]: 0, [userId2]: 0 },
        createdAt: now,
        updatedAt: now,
      });
    }

    return conversationId;
  }

  // ─── Messages ─────────────────────────────────────────────────────────────────

  getMessages(conversationId: string, msgLimit = 50): Observable<Message[]> {
    const ref = collection(
      this.firestore,
      `conversations/${conversationId}/messages`
    );
    const q = query(ref, orderBy('createdAt', 'desc'), limit(msgLimit));
    return collectionData(q, { idField: 'id' }) as Observable<Message[]>;
  }

  async sendMessage(
    conversationId: string,
    message: Omit<Message, 'id' | 'createdAt'>
  ): Promise<void> {
    const messagesRef = collection(
      this.firestore,
      `conversations/${conversationId}/messages`
    );
    const convRef = doc(this.firestore, `conversations/${conversationId}`);

    await addDoc(messagesRef, {
      ...message,
      createdAt: serverTimestamp(),
    });

    // Get the other participant
    const convSnap = await getDoc(convRef);
    const conv = convSnap.data() as Conversation;
    const recipientId = conv.participantIds.find(
      (id) => id !== message.senderId
    );

    const updateData: Record<string, any> = {
      lastMessage: message.text ?? '[Media]',
      lastMessageAt: serverTimestamp(),
      lastMessageSenderId: message.senderId,
      updatedAt: serverTimestamp(),
    };

    if (recipientId) {
      updateData[`unreadCounts.${recipientId}`] = increment(1);
    }

    await updateDoc(convRef, updateData);
  }

  async markConversationAsRead(
    conversationId: string,
    userId: string
  ): Promise<void> {
    const convRef = doc(this.firestore, `conversations/${conversationId}`);
    await updateDoc(convRef, {
      [`unreadCounts.${userId}`]: 0,
    });
  }

  async getTotalUnreadCount(userId: string): Promise<number> {
    const ref = collection(this.firestore, 'conversations');
    const q = query(ref, where('participantIds', 'array-contains', userId));
    const snap = await getDocs(q);
    let total = 0;
    snap.docs.forEach((d) => {
      const data = d.data() as Conversation;
      total += data.unreadCounts[userId] ?? 0;
    });
    return total;
  }
}
