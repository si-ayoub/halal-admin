const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

// Stripe - utiliser placeholder si pas configuré
const stripeKey = functions.config().stripe?.secret_key || 'sk_test_placeholder';
const stripe = require('stripe')(stripeKey);

// ============================================
// FONCTION 1 : AJUSTEMENT NOCTURNE DES RAYONS
// Exécutée chaque nuit à 2h du matin (Europe/Paris)
// ============================================
exports.nightlyRadiusAdjustment = functions
  .region('europe-west1')
  .pubsub
  .schedule('0 2 * * *')
  .timeZone('Europe/Paris')
  .onRun(async (context) => {
    console.log('🌙 Starting nightly radius adjustment...');
    
    try {
      const restaurantsSnapshot = await db.collection('restaurants').get();
      const batch = db.batch();
      let adjustedCount = 0;

      for (const doc of restaurantsSnapshot.docs) {
        const restaurant = doc.data();
        const { vCur, vMin, radius, radiusBase, radiusMax } = restaurant;

        let newRadius = radius;

        // Si objectif atteint ou dépassé : augmenter le rayon de 10%
        if (vCur >= vMin) {
          newRadius = Math.min(radius * 1.1, radiusMax);
          console.log(`✅ ${doc.id}: Objectif atteint (${vCur}/${vMin}) - Rayon: ${radius.toFixed(2)} → ${newRadius.toFixed(2)} km`);
        }
        // Si moins de 50% de l'objectif : diminuer le rayon de 10%
        else if (vCur < vMin * 0.5) {
          newRadius = Math.max(radius * 0.9, radiusBase);
          console.log(`⚠️  ${doc.id}: Sous-performance (${vCur}/${vMin}) - Rayon: ${radius.toFixed(2)} → ${newRadius.toFixed(2)} km`);
        }
        // Entre 50% et 100% : pas de changement
        else {
          console.log(`➡️  ${doc.id}: Performance normale (${vCur}/${vMin}) - Rayon inchangé: ${radius.toFixed(2)} km`);
        }

        // Mettre à jour si changement
        if (newRadius !== radius) {
          batch.update(doc.ref, {
            radius: newRadius,
            lastRadiusUpdate: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          adjustedCount++;
        }
      }

      await batch.commit();
      console.log(`✅ Nightly adjustment completed: ${adjustedCount} restaurants adjusted`);
      
      return { success: true, adjusted: adjustedCount, total: restaurantsSnapshot.size };
    } catch (error) {
      console.error('❌ Error in nightly radius adjustment:', error);
      throw error;
    }
  });

// ============================================
// FONCTION 2 : RESET MENSUEL DES vCur
// Exécutée le 1er de chaque mois à 2h du matin
// ============================================
exports.monthlyReset = functions
  .region('europe-west1')
  .pubsub
  .schedule('0 2 1 * *')
  .timeZone('Europe/Paris')
  .onRun(async (context) => {
    console.log('📅 Starting monthly reset of vCur...');
    
    try {
      const restaurantsSnapshot = await db.collection('restaurants').get();
      const batch = db.batch();

      for (const doc of restaurantsSnapshot.docs) {
        batch.update(doc.ref, {
          vCur: 0,
          monthlyViews: 0,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      console.log(`✅ Monthly reset completed: ${restaurantsSnapshot.size} restaurants reset`);
      
      return { success: true, reset: restaurantsSnapshot.size };
    } catch (error) {
      console.error('❌ Error in monthly reset:', error);
      throw error;
    }
  });

// ============================================
// FONCTION 3 : TRACKING D'IMPRESSION
// Appelée depuis l'app mobile quand un resto est vu
// ============================================
exports.trackImpression = functions
  .region('europe-west1')
  .https
  .onCall(async (data, context) => {
    // Vérifier l'authentification
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { restaurantId, userLatitude, userLongitude } = data;

    if (!restaurantId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'restaurantId is required'
      );
    }

    try {
      const userId = context.auth.uid;
      const batch = db.batch();

      // 1. Incrémenter vCur du restaurant
      const restaurantRef = db.collection('restaurants').doc(restaurantId);
      batch.update(restaurantRef, {
        vCur: admin.firestore.FieldValue.increment(1),
        totalViews: admin.firestore.FieldValue.increment(1),
        monthlyViews: admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2. Logger l'impression
      const impressionRef = db.collection('impressions').doc();
      batch.set(impressionRef, {
        restaurantId,
        userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        latitude: userLatitude || null,
        longitude: userLongitude || null,
      });

      // 3. Mettre à jour le frequency cap de l'utilisateur
      const userViewRef = db.collection('user_views').doc(userId);
      batch.set(
        userViewRef,
        {
          [`viewedRestaurants.${restaurantId}`]: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      await batch.commit();

      console.log(`✅ Impression tracked: ${restaurantId} by ${userId}`);
      
      return { success: true, restaurantId, userId };
    } catch (error) {
      console.error('❌ Error tracking impression:', error);
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

// ============================================
// FONCTION 4 : CALCUL DU SCORE DE VISIBILITÉ
// Appelée depuis l'app pour trier le feed
// ============================================
exports.calculateVisibilityScore = functions
  .region('europe-west1')
  .https
  .onCall(async (data, context) => {
    const { restaurantId, userLatitude, userLongitude } = data;

    if (!restaurantId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'restaurantId is required'
      );
    }

    try {
      const restaurantDoc = await db.collection('restaurants').doc(restaurantId).get();
      
      if (!restaurantDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Restaurant not found');
      }

      const restaurant = restaurantDoc.data();
      
      // Poids de l'algorithme
      const kPlanWeight = 5.0;
      const kBoostWeight = 3.0;
      const kViewsWeight = 2.0;
      const kProximityWeight = 1.0;

      // Priorités par plan
      const planPriorities = {
        'premium_plus': 5.0,
        'premium': 3.0,
        'free': 1.0,
      };

      // P - Priorité du plan
      const P = planPriorities[restaurant.plan] || 1.0;

      // B - Boost (1 si actif, 0 sinon)
      let B = 0.0;
      if (restaurant.boostUntil) {
        const boostUntil = restaurant.boostUntil.toDate();
        B = new Date() < boostUntil ? 1.0 : 0.0;
      }

      // V - Performance vues (ratio vCur/vMin borné à [0,1])
      const V = restaurant.vMin > 0
        ? Math.min(restaurant.vCur / restaurant.vMin, 1.0)
        : 0.0;

      // R - Proximité (si coordonnées fournies)
      let R = 0.0;
      if (userLatitude && userLongitude) {
        const distance = calculateDistance(
          userLatitude,
          userLongitude,
          restaurant.latitude,
          restaurant.longitude
        );
        R = Math.max(0.0, 1.0 - (distance / restaurant.radiusMax));
      }

      // Score final
      const score = (P * kPlanWeight) +
                   (B * kBoostWeight) +
                   (V * kViewsWeight) +
                   (R * kProximityWeight);

      console.log(`📊 Score calculated for ${restaurantId}: ${score.toFixed(2)} (P:${P}, B:${B}, V:${V.toFixed(2)}, R:${R.toFixed(2)})`);

      return {
        restaurantId,
        score: parseFloat(score.toFixed(2)),
        components: {
          plan: P,
          boost: B,
          views: parseFloat(V.toFixed(2)),
          proximity: parseFloat(R.toFixed(2)),
        },
      };
    } catch (error) {
      console.error('❌ Error calculating visibility score:', error);
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

// ============================================
// FONCTION 5 : CRÉER SESSION CHECKOUT STRIPE (Abonnement)
// ============================================
exports.createCheckoutSession = functions
  .region('europe-west1')
  .https
  .onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { restaurantId, planId, successUrl, cancelUrl } = data;

    if (!restaurantId || !planId) {
      throw new functions.https.HttpsError('invalid-argument', 'restaurantId and planId are required');
    }

    try {
      // Récupérer les infos du plan
      const plans = {
        'premium': {
          priceId: 'price_premium_monthly', // À remplacer par votre Price ID Stripe
          name: 'Premium',
          price: 60,
        },
        'premium_plus': {
          priceId: 'price_premium_plus_monthly', // À remplacer par votre Price ID Stripe
          name: 'Premium+',
          price: 80,
        },
      };

      const plan = plans[planId];
      if (!plan) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid plan');
      }

      // Créer la session Stripe Checkout
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        mode: 'subscription',
        line_items: [
          {
            price: plan.priceId,
            quantity: 1,
          },
        ],
        metadata: {
          restaurantId,
          planId,
          userId: context.auth.uid,
        },
        success_url: successUrl || 'https://your-app.com/success',
        cancel_url: cancelUrl || 'https://your-app.com/cancel',
      });

      console.log(`✅ Checkout session created: ${session.id} for ${planId}`);

      return { sessionId: session.id, url: session.url };
    } catch (error) {
      console.error('❌ Error creating checkout session:', error);
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

// ============================================
// FONCTION 6 : CRÉER SESSION CHECKOUT STRIPE (Boost)
// ============================================
exports.createBoostCheckoutSession = functions
  .region('europe-west1')
  .https
  .onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { restaurantId, boostId, successUrl, cancelUrl } = data;

    if (!restaurantId || !boostId) {
      throw new functions.https.HttpsError('invalid-argument', 'restaurantId and boostId are required');
    }

    try {
      const boosts = {
        'boost_1_week': {
          priceId: 'price_boost_1_week', // À remplacer par votre Price ID Stripe
          name: 'Boost 1 Semaine',
          price: 150,
          duration: 7,
        },
        'boost_1_month': {
          priceId: 'price_boost_1_month', // À remplacer par votre Price ID Stripe
          name: 'Boost 1 Mois',
          price: 390,
          duration: 30,
        },
      };

      const boost = boosts[boostId];
      if (!boost) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid boost');
      }

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        mode: 'payment',
        line_items: [
          {
            price: boost.priceId,
            quantity: 1,
          },
        ],
        metadata: {
          restaurantId,
          boostId,
          duration: boost.duration,
          userId: context.auth.uid,
        },
        success_url: successUrl || 'https://your-app.com/success',
        cancel_url: cancelUrl || 'https://your-app.com/cancel',
      });

      console.log(`✅ Boost checkout session created: ${session.id} for ${boostId}`);

      return { sessionId: session.id, url: session.url };
    } catch (error) {
      console.error('❌ Error creating boost checkout session:', error);
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

// ============================================
// FONCTION 7 : WEBHOOK STRIPE
// Gère les événements Stripe (paiement réussi, etc.)
// ============================================
exports.stripeWebhook = functions
  .region('europe-west1')
  .https
  .onRequest(async (req, res) => {
    const sig = req.headers['stripe-signature'];
    const endpointSecret = functions.config().stripe.webhook_secret;

    let event;

    try {
      event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
    } catch (err) {
      console.error('❌ Webhook signature verification failed:', err.message);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    console.log(`📨 Stripe webhook received: ${event.type}`);

    // Gérer les différents types d'événements
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object);
        break;
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object);
        break;
      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object);
        break;
      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  });

// Handler: Checkout complété
async function handleCheckoutCompleted(session) {
  const { restaurantId, planId, boostId, duration } = session.metadata;

  try {
    if (planId) {
      // Abonnement
      const plans = {
        'premium': { vMin: 80000, radiusBase: 5.0, radiusMax: 8.0, priorityBase: 3.0 },
        'premium_plus': { vMin: 100000, radiusBase: 8.0, radiusMax: 10.0, priorityBase: 5.0 },
      };

      const planData = plans[planId];
      const now = admin.firestore.Timestamp.now();
      const endDate = new Date();
      endDate.setMonth(endDate.getMonth() + 1);

      await db.collection('restaurants').doc(restaurantId).update({
        plan: planId,
        subscriptionStartDate: now,
        subscriptionEndDate: admin.firestore.Timestamp.fromDate(endDate),
        vMin: planData.vMin,
        radiusBase: planData.radiusBase,
        radiusMax: planData.radiusMax,
        priorityBase: planData.priorityBase,
        radius: planData.radiusBase,
        updatedAt: now,
      });

      // Logger le paiement
      await db.collection('payments').add({
        restaurantId,
        type: 'subscription',
        planId,
        amount: session.amount_total / 100,
        currency: session.currency,
        status: 'succeeded',
        stripeSessionId: session.id,
        timestamp: now,
      });

      console.log(`✅ Subscription activated: ${planId} for ${restaurantId}`);
    } else if (boostId) {
      // Boost
      const boostUntil = new Date();
      boostUntil.setDate(boostUntil.getDate() + parseInt(duration));

      await db.collection('restaurants').doc(restaurantId).update({
        boostUntil: admin.firestore.Timestamp.fromDate(boostUntil),
        boostMultiplier: 1.5,
        updatedAt: admin.firestore.Timestamp.now(),
      });

      await db.collection('payments').add({
        restaurantId,
        type: 'boost',
        boostId,
        duration,
        amount: session.amount_total / 100,
        currency: session.currency,
        status: 'succeeded',
        stripeSessionId: session.id,
        timestamp: admin.firestore.Timestamp.now(),
      });

      console.log(`✅ Boost activated: ${boostId} for ${restaurantId}`);
    }
  } catch (error) {
    console.error('❌ Error handling checkout completed:', error);
  }
}

// Handler: Abonnement supprimé
async function handleSubscriptionDeleted(subscription) {
  // Trouver le restaurant concerné
  const paymentsSnapshot = await db.collection('payments')
    .where('stripeSessionId', '==', subscription.id)
    .limit(1)
    .get();

  if (!paymentsSnapshot.empty) {
    const payment = paymentsSnapshot.docs[0].data();
    const restaurantId = payment.restaurantId;

    await db.collection('restaurants').doc(restaurantId).update({
      plan: 'free',
      subscriptionEndDate: null,
      vMin: 10000,
      radiusBase: 2.0,
      radiusMax: 5.0,
      priorityBase: 1.0,
      radius: 2.0,
      updatedAt: admin.firestore.Timestamp.now(),
    });

    console.log(`✅ Subscription cancelled for ${restaurantId}`);
  }
}

// Handler: Échec de paiement
async function handlePaymentFailed(invoice) {
  console.log(`⚠️  Payment failed for invoice: ${invoice.id}`);
  // Envoyer une notification au restaurant, etc.
}

// ============================================
// FONCTION UTILITAIRE : CALCUL DE DISTANCE (Haversine)
// ============================================
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Rayon de la Terre en km
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);

  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c; // Distance en km
}

function toRadians(degrees) {
  return degrees * (Math.PI / 180);
}