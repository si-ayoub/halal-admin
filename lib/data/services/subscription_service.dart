// lib/data/services/subscription_service.dart
// HALAL ADMIN - Service de gestion des abonnements Stripe

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Plans disponibles avec prix
  static const Map<String, Map<String, dynamic>> plans = {
    'free': {
      'name': 'Gratuit',
      'price': 0,
      'vMin': 10000,
      'radiusBase': 2.0,
      'radiusMax': 5.0,
      'priorityBase': 1.0,
      'features': [
        'Rayon 2-5 km',
        '10K vues/mois',
        'Statistiques basiques',
      ],
    },
    'premium': {
      'name': 'Premium',
      'price': 60, // €/mois
      'stripePriceId': 'price_premium_monthly', // À configurer dans Stripe
      'vMin': 80000,
      'radiusBase': 5.0,
      'radiusMax': 8.0,
      'priorityBase': 3.0,
      'features': [
        'Rayon 5-8 km',
        '80K vues/mois',
        'Statistiques avancées',
        'Support prioritaire',
        'Badge Premium',
      ],
    },
    'premium_plus': {
      'name': 'Premium+',
      'price': 80, // €/mois
      'stripePriceId': 'price_premium_plus_monthly', // À configurer dans Stripe
      'vMin': 100000,
      'radiusBase': 8.0,
      'radiusMax': 10.0,
      'priorityBase': 5.0,
      'features': [
        'Rayon 8-10 km',
        '100K vues/mois',
        'Statistiques premium',
        'Support VIP 24/7',
        'Badge Premium+',
        'Boost mensuel gratuit',
      ],
    },
  };

  // Boosts disponibles
  static const Map<String, Map<String, dynamic>> boosts = {
    'boost_1_week': {
      'name': 'Boost 1 Semaine',
      'price': 150,
      'stripePriceId': 'price_boost_1_week',
      'duration': 7, // jours
      'multiplier': 1.5,
    },
    'boost_1_month': {
      'name': 'Boost 1 Mois',
      'price': 390,
      'stripePriceId': 'price_boost_1_month',
      'duration': 30, // jours
      'multiplier': 1.5,
    },
  };

  // Créer une session de paiement Stripe
  Future<String?> createCheckoutSession({
    required String restaurantId,
    required String planId,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final callable = _functions.httpsCallable('createCheckoutSession');
      final result = await callable.call({
        'restaurantId': restaurantId,
        'planId': planId,
        'successUrl': successUrl ?? 'https://your-app.com/success',
        'cancelUrl': cancelUrl ?? 'https://your-app.com/cancel',
      });

      return result.data['sessionId'] as String?;
    } catch (e) {
      print('Error creating checkout session: $e');
      return null;
    }
  }

  // Créer une session pour un boost
  Future<String?> createBoostCheckoutSession({
    required String restaurantId,
    required String boostId,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final callable = _functions.httpsCallable('createBoostCheckoutSession');
      final result = await callable.call({
        'restaurantId': restaurantId,
        'boostId': boostId,
        'successUrl': successUrl ?? 'https://your-app.com/success',
        'cancelUrl': cancelUrl ?? 'https://your-app.com/cancel',
      });

      return result.data['sessionId'] as String?;
    } catch (e) {
      print('Error creating boost checkout session: $e');
      return null;
    }
  }

  // Mettre à jour l'abonnement d'un restaurant
  Future<void> updateSubscription({
    required String restaurantId,
    required String planId,
  }) async {
    try {
      final planData = plans[planId];
      if (planData == null) return;

      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month + 1, now.day);

      await _firestore.collection('restaurants').doc(restaurantId).update({
        'plan': planId,
        'subscriptionStartDate': FieldValue.serverTimestamp(),
        'subscriptionEndDate': Timestamp.fromDate(endDate),
        'vMin': planData['vMin'],
        'radiusBase': planData['radiusBase'],
        'radiusMax': planData['radiusMax'],
        'priorityBase': planData['priorityBase'],
        'radius': planData['radiusBase'], // Reset au rayon de base
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating subscription: $e');
    }
  }

  // Activer un boost
  Future<void> activateBoost({
    required String restaurantId,
    required String boostId,
  }) async {
    try {
      final boostData = boosts[boostId];
      if (boostData == null) return;

      final now = DateTime.now();
      final boostUntil = now.add(Duration(days: boostData['duration']));

      await _firestore.collection('restaurants').doc(restaurantId).update({
        'boostUntil': Timestamp.fromDate(boostUntil),
        'boostMultiplier': boostData['multiplier'],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error activating boost: $e');
    }
  }

  // Annuler un abonnement
  Future<void> cancelSubscription({
    required String restaurantId,
  }) async {
    try {
      await _firestore.collection('restaurants').doc(restaurantId).update({
        'plan': 'free',
        'subscriptionEndDate': null,
        'vMin': plans['free']!['vMin'],
        'radiusBase': plans['free']!['radiusBase'],
        'radiusMax': plans['free']!['radiusMax'],
        'priorityBase': plans['free']!['priorityBase'],
        'radius': plans['free']!['radiusBase'],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error canceling subscription: $e');
    }
  }

  // Vérifier l'état de l'abonnement
  Future<Map<String, dynamic>> checkSubscriptionStatus({
    required String restaurantId,
  }) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(restaurantId).get();
      if (!doc.exists) {
        return {'status': 'not_found'};
      }

      final data = doc.data() as Map<String, dynamic>;
      final plan = data['plan'] ?? 'free';
      final endDate = data['subscriptionEndDate'] as Timestamp?;

      if (plan == 'free') {
        return {
          'status': 'free',
          'plan': plan,
        };
      }

      if (endDate == null) {
        return {
          'status': 'inactive',
          'plan': plan,
        };
      }

      final isActive = DateTime.now().isBefore(endDate.toDate());

      return {
        'status': isActive ? 'active' : 'expired',
        'plan': plan,
        'endDate': endDate.toDate().toIso8601String(),
        'daysRemaining': endDate.toDate().difference(DateTime.now()).inDays,
      };
    } catch (e) {
      print('Error checking subscription status: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // Obtenir l'historique des paiements
  Future<List<Map<String, dynamic>>> getPaymentHistory({
    required String restaurantId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'amount': data['amount'],
          'currency': data['currency'] ?? 'eur',
          'type': data['type'], // 'subscription' ou 'boost'
          'status': data['status'], // 'succeeded', 'pending', 'failed'
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      print('Error getting payment history: $e');
      return [];
    }
  }

  // Calculer les économies avec un plan annuel
  Map<String, dynamic> calculateAnnualSavings(String planId) {
    final planData = plans[planId];
    if (planData == null) return {};

    final monthlyPrice = planData['price'] as int;
    final annualPrice = (monthlyPrice * 12 * 0.85).round(); // 15% de réduction
    final savings = (monthlyPrice * 12) - annualPrice;

    return {
      'monthlyPrice': monthlyPrice,
      'annualPrice': annualPrice,
      'monthlySavings': (savings / 12).round(),
      'totalSavings': savings,
      'savingsPercentage': 15,
    };
  }
}