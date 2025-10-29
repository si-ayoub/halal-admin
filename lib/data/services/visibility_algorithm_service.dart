// lib/data/services/visibility_algorithm_service.dart
// HALAL ADMIN - Service de calcul du score de visibilité

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class VisibilityAlgorithmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constantes de l'algorithme
  static const double kPlanWeight = 5.0; // Poids du plan
  static const double kBoostWeight = 3.0; // Poids du boost
  static const double kViewsWeight = 2.0; // Poids des vues
  static const double kProximityWeight = 1.0; // Poids de la proximité

  // Valeurs de priorité par plan
  static const Map<String, double> kPlanPriorities = {
    'premium_plus': 5.0,
    'premium': 3.0,
    'free': 1.0,
  };

  // Calcul du score de visibilité S_i
  // Formule: S_i = (P × 5) + (B × 3) + (V × 2) + (R × 1)
  double calculateVisibilityScore({
    required RestaurantModel restaurant,
    double? userLatitude,
    double? userLongitude,
  }) {
    // P - Priorité du plan
    final double P = kPlanPriorities[restaurant.plan] ?? 1.0;

    // B - Boost (1 si actif, 0 sinon)
    final double B = restaurant.hasActiveBoost ? 1.0 : 0.0;

    // V - Performance vues (ratio vCur/vMin borné à [0,1])
    final double V = restaurant.vMin > 0
        ? (restaurant.vCur / restaurant.vMin).clamp(0.0, 1.0)
        : 0.0;

    // R - Proximité (si coordonnées fournies)
    double R = 0.0;
    if (userLatitude != null && userLongitude != null) {
      final distance = _calculateDistance(
        userLatitude,
        userLongitude,
        restaurant.latitude,
        restaurant.longitude,
      );
      // R = 1 - (distance / rayon_max)
      // Plus c'est proche, plus R est élevé
      R = (1.0 - (distance / restaurant.radiusMax)).clamp(0.0, 1.0);
    }

    // Score final
    final score = (P * kPlanWeight) +
        (B * kBoostWeight) +
        (V * kViewsWeight) +
        (R * kProximityWeight);

    return score;
  }

  // Ajustement dynamique du rayon
  // Appelé par Cloud Function chaque nuit à 2h
  Future<void> adjustRadius(String restaurantId) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(restaurantId).get();
      if (!doc.exists) return;

      final restaurant = RestaurantModel.fromFirestore(doc);
      double newRadius = restaurant.radius;

      // Si objectif atteint (vCur >= vMin), augmenter le rayon
      if (restaurant.vCur >= restaurant.vMin) {
        newRadius = (restaurant.radius * 1.1).clamp(
          restaurant.radiusBase,
          restaurant.radiusMax,
        );
      }
      // Si sous-performance, diminuer le rayon
      else {
        final performance = restaurant.vCur / restaurant.vMin;
        if (performance < 0.5) {
          // Moins de 50% de l'objectif
          newRadius = (restaurant.radius * 0.9).clamp(
            restaurant.radiusBase,
            restaurant.radiusMax,
          );
        }
      }

      // Mise à jour Firestore
      if (newRadius != restaurant.radius) {
        await _firestore.collection('restaurants').doc(restaurantId).update({
          'radius': newRadius,
          'lastRadiusUpdate': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adjusting radius for $restaurantId: $e');
    }
  }

  // Ajustement en masse (pour tous les restos)
  Future<void> adjustAllRadii() async {
    try {
      final snapshot = await _firestore.collection('restaurants').get();
      for (final doc in snapshot.docs) {
        await adjustRadius(doc.id);
      }
    } catch (e) {
      print('Error adjusting all radii: $e');
    }
  }

  // Reset mensuel des vCur (1er du mois à 2h)
  Future<void> monthlyReset() async {
    try {
      final snapshot = await _firestore.collection('restaurants').get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'vCur': 0,
          'monthlyViews': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error in monthly reset: $e');
    }
  }

  // Vérifier si un restaurant est dans le rayon d'un utilisateur
  bool isWithinRadius({
    required RestaurantModel restaurant,
    required double userLatitude,
    required double userLongitude,
  }) {
    final distance = _calculateDistance(
      userLatitude,
      userLongitude,
      restaurant.latitude,
      restaurant.longitude,
    );
    return distance <= restaurant.radius;
  }

  // Calculer la distance entre deux points (formule Haversine)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Statistiques de visibilité pour dashboard
  Future<Map<String, dynamic>> getVisibilityStats(String restaurantId) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(restaurantId).get();
      if (!doc.exists) {
        return {
          'error': 'Restaurant not found',
        };
      }

      final restaurant = RestaurantModel.fromFirestore(doc);

      // Calculer le score actuel (sans coordonnées utilisateur)
      final currentScore = calculateVisibilityScore(restaurant: restaurant);

      // Projection fin de mois
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final daysPassed = now.day;
      final daysRemaining = daysInMonth - daysPassed;

      final dailyAverage = daysPassed > 0 ? restaurant.vCur / daysPassed : 0;
      final projectedEndMonth = restaurant.vCur + (dailyAverage * daysRemaining);

      return {
        'currentScore': currentScore.toStringAsFixed(2),
        'vCur': restaurant.vCur,
        'vMin': restaurant.vMin,
        'progressPercentage': restaurant.progressPercentage.toStringAsFixed(1),
        'viewsRemaining': restaurant.viewsRemaining,
        'radius': restaurant.radius.toStringAsFixed(1),
        'radiusBase': restaurant.radiusBase.toStringAsFixed(1),
        'radiusMax': restaurant.radiusMax.toStringAsFixed(1),
        'plan': restaurant.plan,
        'hasActiveBoost': restaurant.hasActiveBoost,
        'boostUntil': restaurant.boostUntil?.toIso8601String(),
        'performanceStatus': restaurant.performanceStatus,
        'dailyAverage': dailyAverage.toStringAsFixed(0),
        'projectedEndMonth': projectedEndMonth.toStringAsFixed(0),
        'onTrack': projectedEndMonth >= restaurant.vMin,
        'lastRadiusUpdate': restaurant.lastRadiusUpdate?.toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Error fetching stats: $e',
      };
    }
  }

  // Simuler l'impact d'un upgrade de plan
  Map<String, dynamic> simulateUpgrade({
    required RestaurantModel restaurant,
    required String newPlan,
  }) {
    final currentScore = calculateVisibilityScore(restaurant: restaurant);

    // Créer une copie avec le nouveau plan
    final upgradedRestaurant = restaurant.copyWith(
      plan: newPlan,
      priorityBase: kPlanPriorities[newPlan] ?? 1.0,
      vMin: RestaurantModel(
        id: '',
        name: '',
        latitude: 0,
        longitude: 0,
        plan: newPlan,
      ).vMin,
    );

    final newScore = calculateVisibilityScore(restaurant: upgradedRestaurant);

    return {
      'currentPlan': restaurant.plan,
      'newPlan': newPlan,
      'currentScore': currentScore.toStringAsFixed(2),
      'newScore': newScore.toStringAsFixed(2),
      'scoreIncrease': (newScore - currentScore).toStringAsFixed(2),
      'currentVMin': restaurant.vMin,
      'newVMin': upgradedRestaurant.vMin,
      'potentialReach': '${(upgradedRestaurant.vMin / 1000).toStringAsFixed(0)}K vues/mois',
    };
  }
}