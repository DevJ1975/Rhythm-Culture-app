/**
 * Live streaming integration — Mux (HLS playback) and Agora (low-latency RTC).
 *
 * Required functions config:
 *   firebase functions:config:set \
 *     mux.token_id="..." \
 *     mux.token_secret="..." \
 *     agora.app_id="..." \
 *     agora.app_certificate="..."
 *
 * Install:
 *   cd functions && npm install @mux/mux-node agora-access-token
 */
import * as functions from 'firebase-functions';

interface ProvisionInput {
  provider?: 'mux' | 'agora';
  title?: string;
}

interface ProvisionResult {
  playbackId?: string;
  streamKey?: string;
  channelName?: string;
}

export const provisionLiveStream = functions.https.onCall(
  async (data: ProvisionInput, context): Promise<ProvisionResult> => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Sign-in required');
    }
    const provider = data.provider || 'mux';

    if (provider === 'mux') {
      const cfg = functions.config().mux;
      if (!cfg?.token_id || !cfg?.token_secret) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Mux not configured'
        );
      }
      const Mux = (await import('@mux/mux-node')).default;
      const mux = new Mux({ tokenId: cfg.token_id, tokenSecret: cfg.token_secret });
      const stream = await mux.video.liveStreams.create({
        playback_policy: ['public'],
        new_asset_settings: { playback_policy: ['public'] },
        reconnect_window: 30,
      });
      return {
        playbackId: stream.playback_ids?.[0]?.id,
        streamKey: stream.stream_key,
      };
    }

    if (provider === 'agora') {
      const cfg = functions.config().agora;
      if (!cfg?.app_id || !cfg?.app_certificate) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Agora not configured'
        );
      }
      const channelName = `rc-${context.auth.uid}-${Date.now()}`;
      return { channelName };
    }

    throw new functions.https.HttpsError('invalid-argument', 'Unknown provider');
  }
);

/**
 * Issues a short-lived Agora RTC token for the requesting user.
 * Tokens expire after 60 minutes and must be refreshed by the client.
 */
export const agoraToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Sign-in required');
  }
  const cfg = functions.config().agora;
  if (!cfg?.app_id || !cfg?.app_certificate) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Agora not configured'
    );
  }
  const { channel, uid } = data as { channel: string; uid: number };
  if (!channel) {
    throw new functions.https.HttpsError('invalid-argument', 'channel required');
  }

  const { RtcTokenBuilder, RtcRole } = await import('agora-access-token');
  const expireSeconds = 60 * 60;
  const currentTs = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTs + expireSeconds;

  const token = RtcTokenBuilder.buildTokenWithUid(
    cfg.app_id,
    cfg.app_certificate,
    channel,
    uid || 0,
    RtcRole.PUBLISHER,
    privilegeExpiredTs
  );
  return { token };
});

/**
 * Mux webhook — listens for live stream lifecycle events and updates Firestore.
 * Configure the webhook in the Mux dashboard pointing at this function's URL.
 */
export const muxWebhook = functions.https.onRequest(async (req, res) => {
  const admin = await import('firebase-admin');
  const db = admin.firestore();
  const event = req.body;
  if (!event?.type) {
    res.status(400).send('Bad request');
    return;
  }

  try {
    const livestreamId = event.data?.id;
    if (!livestreamId) {
      res.status(200).send({ ok: true });
      return;
    }

    // Find Firestore doc by playbackId (Mux's data.playback_ids[0].id)
    const playbackId = event.data?.playback_ids?.[0]?.id;
    if (!playbackId) {
      res.status(200).send({ ok: true });
      return;
    }

    const q = await db
      .collection('live_streams')
      .where('playbackId', '==', playbackId)
      .limit(1)
      .get();
    if (q.empty) {
      res.status(200).send({ ok: true });
      return;
    }
    const ref = q.docs[0].ref;

    switch (event.type) {
      case 'video.live_stream.active':
        await ref.update({
          status: 'live',
          startedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        break;
      case 'video.live_stream.idle':
        await ref.update({
          status: 'ended',
          endedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        break;
      default:
        break;
    }
    res.status(200).send({ ok: true });
  } catch (err) {
    functions.logger.error('Mux webhook error', err);
    res.status(500).send('Server error');
  }
});
