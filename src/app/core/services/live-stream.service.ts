import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  addDoc,
  updateDoc,
  getDoc,
  query,
  where,
  orderBy,
  collectionData,
  serverTimestamp,
  Timestamp,
} from '@angular/fire/firestore';
import { Functions, httpsCallable } from '@angular/fire/functions';
import { Observable } from 'rxjs';

export type LiveStreamStatus = 'scheduled' | 'live' | 'ended';

export interface LiveStream {
  id: string;
  hostId: string;
  courseId?: string;
  lessonId?: string;
  title: string;
  description?: string;
  status: LiveStreamStatus;
  scheduledAt?: Timestamp;
  startedAt?: Timestamp;
  endedAt?: Timestamp;
  // Provider-specific bits (Mux or Agora)
  provider: 'mux' | 'agora';
  playbackId?: string;     // Mux
  streamKey?: string;       // Mux (for OBS / RTMP push)
  channelName?: string;     // Agora
  rtcToken?: string;        // Agora — ephemeral, fetched on demand
  viewersCount: number;
  createdAt: Timestamp;
}

/**
 * Wraps live streaming. Uses Mux (HLS playback for everyone) by default and
 * exposes an Agora token endpoint for low-latency interactive streams.
 *
 * Required config (server-side, see functions/src/live/streaming.ts):
 *   live.provider="mux"
 *   mux.token_id, mux.token_secret
 *   agora.app_id, agora.app_certificate
 */
@Injectable({ providedIn: 'root' })
export class LiveStreamService {
  private firestore = inject(Firestore);
  private functions = inject(Functions);

  upcoming(): Observable<LiveStream[]> {
    const ref = collection(this.firestore, 'live_streams');
    const q = query(
      ref,
      where('status', 'in', ['scheduled', 'live']),
      orderBy('scheduledAt', 'asc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<LiveStream[]>;
  }

  async createStream(
    hostId: string,
    title: string,
    options: Partial<LiveStream> = {}
  ): Promise<{ stream: LiveStream; playbackId?: string; streamKey?: string }> {
    // Provision on the chosen provider via the callable function
    const provision = httpsCallable<
      { provider?: 'mux' | 'agora'; title: string },
      { playbackId?: string; streamKey?: string; channelName?: string }
    >(this.functions, 'provisionLiveStream');
    const { data } = await provision({
      provider: options.provider || 'mux',
      title,
    });

    const ref = collection(this.firestore, 'live_streams');
    const docRef = await addDoc(ref, {
      hostId,
      title,
      description: options.description ?? '',
      status: options.scheduledAt ? 'scheduled' : 'live',
      scheduledAt: options.scheduledAt ?? null,
      provider: options.provider || 'mux',
      playbackId: data.playbackId ?? null,
      streamKey: data.streamKey ?? null,
      channelName: data.channelName ?? null,
      courseId: options.courseId ?? null,
      lessonId: options.lessonId ?? null,
      viewersCount: 0,
      createdAt: serverTimestamp(),
    });
    const snap = await getDoc(docRef);
    return {
      stream: { ...(snap.data() as LiveStream), id: snap.id },
      playbackId: data.playbackId,
      streamKey: data.streamKey,
    };
  }

  async endStream(streamId: string): Promise<void> {
    const ref = doc(this.firestore, `live_streams/${streamId}`);
    await updateDoc(ref, {
      status: 'ended',
      endedAt: serverTimestamp(),
    });
  }

  async getAgoraToken(channelName: string, uid: number): Promise<string> {
    const fn = httpsCallable<{ channel: string; uid: number }, { token: string }>(
      this.functions,
      'agoraToken'
    );
    const { data } = await fn({ channel: channelName, uid });
    return data.token;
  }
}
