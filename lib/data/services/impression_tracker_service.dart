// lib/data/services/impression_tracker_service.dart
// HALAL ADMIN - Service de tracking des impressions/vues

import 'package:cloud_firestore/cloud_firestore.dart';

class ImpressionTrackerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enregistrer une impression
  Future<void> trackImpression({
    required String restaurantId,
    required String userId,
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Incrémenter vCur du restaurant
      final restaurantRef = _firestore.collection('restaurants').doc(restaurantId);
      batch.update(restaurantRef, {
        'vCur': FieldValue.increment(1),
        'totalViews': FieldValue.increment(1),
        'monthlyViews': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Logger l'impression dans une collection dédiée
      final impressionRef = _firestore.collection('impressions').doc();
      batch.set(impressionRef, {
        'restaurantId': restaurantId,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'latitude': userLatitude,
        'longitude': userLongitude,
      });

      // 3. Mettre à jour le frequency cap de l'utilisateur
      final userViewRef = _firestore.collection('user_views').doc(userId);
      batch.set(
        userViewRef,
        {
          'viewedRestaurants.$restaurantId': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      print('Error tracking impression: $e');
    }
  }

  // Vérifier si un utilisateur peut voir un resto (frequency cap 24h)
  Future<bool> canViewRestaurant({
    required String userId,
    required String restaurantId,
  }) async {
    try {
      final doc = await _firestore.collection('user_views').doc(userId).get();
      
      if (!doc.exists) return true;

      final data = doc.data() as Map<String, dynamic>;
      final viewedRestaurants = data['viewedRestaurants'] as Map<String, dynamic>?;

      if (viewedRestaurants == null || !viewedRestaurants.containsKey(restaurantId)) {
        return true;
      }

      final lastView = (viewedRestaurants[restaurantId] as Timestamp).toDate();
      final hoursSinceLastView = DateTime.now().difference(lastView).inHours;

      return hoursSinceLastView >= 24;
    } catch (e) {
      print('Error checking frequency cap: $e');
      return true; // En cas d'erreur, autoriser la vue
    }
  }

  // Obtenir le nombre d'impressions sur une période
  Future<int> getImpressionCount({
    required String restaurantId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('impressions')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting impression count: $e');
      return 0;
    }
  }

  // Obtenir les impressions par jour (pour graphiques)
  Future<Map<String, int>> getDailyImpressions({
    required String restaurantId,
    required int days,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection('impressions')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('timestamp', descending: false)
          .get();

      final Map<String, int> dailyCount = {};

      // Initialiser tous les jours à 0
      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        dailyCount[dateKey] = 0;
      }

      // Compter les impressions par jour
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final dateKey = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
        
        if (dailyCount.containsKey(dateKey)) {
          dailyCount[dateKey] = dailyCount[dateKey]! + 1;
        }
      }

      return dailyCount;
    } catch (e) {
      print('Error getting daily impressions: $e');
      return {};
    }
  }

  // Obtenir les impressions par heure (dernières 24h)
  Future<Map<int, int>> getHourlyImpressions({
    required String restaurantId,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(hours: 24));

      final snapshot = await _firestore
          .collection('impressions')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      final Map<int, int> hourlyCount = {};

      // Initialiser toutes les heures à 0
      for (int i = 0; i < 24; i++) {
        hourlyCount[i] = 0;
      }

      // Compter les impressions par heure
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final hour = timestamp.hour;
        
        hourlyCount[hour] = (hourlyCount[hour] ?? 0) + 1;
      }

      return hourlyCount;
    } catch (e) {
      print('Error getting hourly impressions: $e');
      return {};
    }
  }

  // Obtenir les stats géographiques des impressions
  Future<List<Map<String, dynamic>>> getGeographicImpressions({
    required String restaurantId,
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('impressions')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('latitude', isNotEqualTo: null)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      print('Error getting geographic impressions: $e');
      return [];
    }
  }

  // Nettoyer les anciennes impressions (> 3 mois)
  Future<void> cleanOldImpressions() async {
    try {
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      
      final snapshot = await _firestore
          .collection('impressions')
          .where('timestamp', isLessThan: Timestamp.fromDate(threeMonthsAgo))
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Cleaned ${snapshot.docs.length} old impressions');
    } catch (e) {
      print('Error cleaning old impressions: $e');
    }
  }

  // Stats globales pour un restaurant
  Future<Map<String, dynamic>> getRestaurantStats({
    required String restaurantId,
  }) async {
    try {
      final now = DateTime.now();
      
      // Impressions aujourd'hui
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayCount = await getImpressionCount(
        restaurantId: restaurantId,
        startDate: todayStart,
        endDate: now,
      );

      // Impressions cette semaine
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekCount = await getImpressionCount(
        restaurantId: restaurantId,
        startDate: weekStart,
        endDate: now,
      );

      // Impressions ce mois
      final monthStart = DateTime(now.year, now.month, 1);
      final monthCount = await getImpressionCount(
        restaurantId: restaurantId,
        startDate: monthStart,
        endDate: now,
      );

      return {
        'today': todayCount,
        'week': weekCount,
        'month': monthCount,
      };
    } catch (e) {
      print('Error getting restaurant stats: $e');
      return {
        'today': 0,
        'week': 0,
        'month': 0,
      };
    }
  }
}