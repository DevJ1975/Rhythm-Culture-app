/**
 * Search indexing — keeps `*_lower` denormalized fields in sync for cheap
 * prefix queries, and optionally mirrors documents to Algolia/Typesense when
 * configured.
 *
 * Configure external search:
 *   firebase functions:config:set \
 *     search.provider="algolia" \
 *     search.algolia_app_id="..." \
 *     search.algolia_admin_key="..."
 *
 *   firebase functions:config:set \
 *     search.provider="typesense" \
 *     search.typesense_host="..." \
 *     search.typesense_api_key="..."
 *
 * Without provider config the functions only maintain the lowercase fields.
 */
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

function lower(s: any): string {
  return typeof s === 'string' ? s.toLowerCase() : '';
}

async function mirrorToSearch(
  index: string,
  id: string,
  data: Record<string, unknown> | null
): Promise<void> {
  const cfg = functions.config().search || {};
  if (!cfg.provider) return;
  try {
    if (cfg.provider === 'algolia' && cfg.algolia_app_id && cfg.algolia_admin_key) {
      const algoliasearch = (await import('algoliasearch')).default;
      const client = algoliasearch(cfg.algolia_app_id, cfg.algolia_admin_key);
      const idx = client.initIndex(index);
      if (data) {
        await idx.saveObject({ objectID: id, ...data });
      } else {
        await idx.deleteObject(id);
      }
    } else if (
      cfg.provider === 'typesense' &&
      cfg.typesense_host &&
      cfg.typesense_api_key
    ) {
      // Lazy import; users can install typesense if they choose this provider.
      const Typesense = (await import('typesense')).default;
      const client = new Typesense.Client({
        nodes: [{ host: cfg.typesense_host, port: 443, protocol: 'https' }],
        apiKey: cfg.typesense_api_key,
        connectionTimeoutSeconds: 5,
      });
      if (data) {
        await client.collections(index).documents().upsert({ id, ...data });
      } else {
        await client.collections(index).documents(id).delete();
      }
    }
  } catch (err) {
    functions.logger.warn(`Search mirror to ${index} failed for ${id}:`, err);
  }
}

export const indexUserOnWrite = functions.firestore
  .document('users/{uid}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data()! : null;
    const before = change.before.exists ? change.before.data()! : null;
    const uid = context.params.uid;

    if (!after) {
      await mirrorToSearch('users', uid, null);
      return;
    }

    const wantLower = lower(after['displayName']);
    if (after['displayName_lower'] !== wantLower) {
      await change.after.ref.update({ displayName_lower: wantLower });
    }
    if (
      !before ||
      before['displayName'] !== after['displayName'] ||
      before['artistName'] !== after['artistName'] ||
      before['isVerified'] !== after['isVerified']
    ) {
      await mirrorToSearch('users', uid, {
        displayName: after['displayName'],
        artistName: after['artistName'],
        photoURL: after['photoURL'],
        specialties: after['specialties'],
        isVerified: after['isVerified'],
        isPro: after['isPro'],
      });
    }
  });

export const indexPostOnWrite = functions.firestore
  .document('posts/{postId}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data()! : null;
    const postId = context.params.postId;

    if (!after) {
      await mirrorToSearch('posts', postId, null);
      // Also decrement hashtag counts
      return;
    }
    const wantLower = lower(after['caption'] || '');
    if (after['caption_lower'] !== wantLower) {
      await change.after.ref.update({ caption_lower: wantLower });
    }
    await mirrorToSearch('posts', postId, {
      authorId: after['authorId'],
      caption: after['caption'],
      tags: after['tags'],
      type: after['type'],
      createdAt: after['createdAt'],
    });

    // Maintain trending-style hashtag counters
    const tags: string[] = after['tags'] || [];
    if (tags.length > 0 && !change.before.exists) {
      const batch = db.batch();
      tags.forEach((tag) => {
        const ref = db.doc(`hashtags/${tag.toLowerCase()}`);
        batch.set(
          ref,
          {
            tag: tag.toLowerCase(),
            count: admin.firestore.FieldValue.increment(1),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      });
      await batch.commit();
    }
  });

export const indexEventOnWrite = functions.firestore
  .document('events/{id}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data()! : null;
    const id = context.params.id;
    if (!after) {
      await mirrorToSearch('events', id, null);
      return;
    }
    const wantLower = lower(after['title']);
    if (after['title_lower'] !== wantLower) {
      await change.after.ref.update({ title_lower: wantLower });
    }
    await mirrorToSearch('events', id, {
      title: after['title'],
      description: after['description'],
      category: after['category'],
      city: after['location']?.city,
      country: after['location']?.country,
      eventDate: after['eventDate'],
      tags: after['tags'],
    });
  });

export const indexCourseOnWrite = functions.firestore
  .document('courses/{id}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data()! : null;
    const id = context.params.id;
    if (!after) {
      await mirrorToSearch('courses', id, null);
      return;
    }
    const wantLower = lower(after['title']);
    if (after['title_lower'] !== wantLower) {
      await change.after.ref.update({ title_lower: wantLower });
    }
    await mirrorToSearch('courses', id, {
      title: after['title'],
      description: after['description'],
      category: after['category'],
      level: after['level'],
      tags: after['tags'],
      rating: after['rating'],
    });
  });

export const indexCollaborationOnWrite = functions.firestore
  .document('collaborations/{id}')
  .onWrite(async (change, context) => {
    const after = change.after.exists ? change.after.data()! : null;
    const id = context.params.id;
    if (!after) {
      await mirrorToSearch('collaborations', id, null);
      return;
    }
    const wantLower = lower(after['title']);
    if (after['title_lower'] !== wantLower) {
      await change.after.ref.update({ title_lower: wantLower });
    }
    await mirrorToSearch('collaborations', id, {
      title: after['title'],
      description: after['description'],
      type: after['type'],
      skills: after['skills'],
      isRemote: after['isRemote'],
      isPaid: after['isPaid'],
      status: after['status'],
      tags: after['tags'],
    });
  });
