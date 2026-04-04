/**
 * SAM.gov Opportunity Sync — Cloud Function
 *
 * Scheduled to run every 6 hours to pull new contract opportunities
 * from the SAM.gov Opportunities API and store them in Firestore.
 *
 * Currently stubbed with mock data. When a real SAM.gov API key is
 * configured, this function will call:
 *   https://api.sam.gov/opportunities/v2/search
 *
 * Rate limits:
 *   - Public: 10 requests/day
 *   - Individual API key: 1,000 requests/day
 *   - System Account: 10,000 requests/day
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

// Performing arts NAICS codes to search for
const PERFORMING_ARTS_NAICS = [
  '711110', // Theater Companies and Dinner Theaters
  '711120', // Dance Companies
  '711130', // Musical Groups and Artists
  '711190', // Other Performing Arts Companies
  '711310', // Promoters with Facilities
  '711320', // Promoters without Facilities
  '611610', // Fine Arts Schools
  '512110', // Motion Picture Production
  '512240', // Sound Recording Studios
];

/**
 * Scheduled function to sync opportunities from SAM.gov
 * Runs every 6 hours.
 */
export const syncSamOpportunities = functions.pubsub
  .schedule('every 6 hours')
  .onRun(async () => {
    functions.logger.info('Starting SAM.gov opportunity sync...');

    try {
      // TODO: Replace with real SAM.gov API call when API key is available
      //
      // Example API call:
      // const apiKey = functions.config().samgov?.api_key;
      // if (!apiKey) {
      //   functions.logger.warn('No SAM.gov API key configured. Skipping sync.');
      //   return;
      // }
      //
      // const today = new Date();
      // const thirtyDaysAgo = new Date(today.getTime() - 30 * 86400000);
      // const params = new URLSearchParams({
      //   api_key: apiKey,
      //   postedFrom: formatDate(thirtyDaysAgo),
      //   postedTo: formatDate(today),
      //   ncode: PERFORMING_ARTS_NAICS.join(','),
      //   ptype: 'o,p,k',  // solicitations, presolicitations, combined synopsis
      //   limit: '100',
      // });
      //
      // const response = await fetch(
      //   `https://api.sam.gov/opportunities/v2/search?${params}`
      // );
      // const data = await response.json();
      //
      // for (const opp of data.opportunitiesData) {
      //   await db.collection('govcon_opportunities').doc(opp.noticeId).set({
      //     samOpportunityId: opp.noticeId,
      //     title: opp.title,
      //     solicitationNumber: opp.solicitationNumber,
      //     type: mapNoticeType(opp.type),
      //     agency: opp.department,
      //     office: opp.subTier,
      //     description: opp.description || '',
      //     naicsCodes: opp.naicsCode ? [opp.naicsCode] : [],
      //     setAside: mapSetAside(opp.typeOfSetAside),
      //     postedDate: admin.firestore.Timestamp.fromDate(new Date(opp.postedDate)),
      //     responseDeadline: admin.firestore.Timestamp.fromDate(new Date(opp.responseDeadLine)),
      //     placeOfPerformance: {
      //       state: opp.placeOfPerformance?.state?.code,
      //       country: opp.placeOfPerformance?.country?.code,
      //     },
      //     pointOfContact: opp.pointOfContact?.[0] ? {
      //       name: opp.pointOfContact[0].fullName,
      //       email: opp.pointOfContact[0].email,
      //       phone: opp.pointOfContact[0].phone,
      //     } : null,
      //     status: 'active',
      //     syncedAt: admin.firestore.FieldValue.serverTimestamp(),
      //     createdAt: admin.firestore.FieldValue.serverTimestamp(),
      //     updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      //   }, { merge: true });
      // }

      functions.logger.info(
        'SAM.gov sync stubbed — no API key configured. ' +
        `Would search for NAICS codes: ${PERFORMING_ARTS_NAICS.join(', ')}`
      );
    } catch (error) {
      functions.logger.error('SAM.gov sync error:', error);
    }
  });
