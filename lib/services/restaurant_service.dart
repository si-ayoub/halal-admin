import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir tous les restaurants visibles
  Stream<List<RestaurantModel>> getVisibleRestaurants() {
    return _firestore
        .collection('restaurants')
        .where('isVisible', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RestaurantModel.fromFirestore(doc))
            .toList());
  }

  // Obtenir tous les restaurants (pour admin/CEO)
  Stream<List<RestaurantModel>> getAllRestaurants() {
    return _firestore
        .collection('restaurants')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RestaurantModel.fromFirestore(doc))
            .toList());
  }

  // Obtenir un restaurant par ID
  Future<RestaurantModel?> getRestaurant(String id) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(id).get();
      if (doc.exists) {
        return RestaurantModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erreur getRestaurant: $e');
      return null;
    }
  }

  // Obtenir les restaurants d'un propriétaire
  Stream<List<RestaurantModel>> getOwnerRestaurants(String ownerId) {
    return _firestore
        .collection('restaurants')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RestaurantModel.fromFirestore(doc))
            .toList());
  }

  // Créer un restaurant
  Future<String> createRestaurant(RestaurantModel restaurant) async {
    final doc = await _firestore.collection('restaurants').add(
      restaurant.toFirestore(),
    );
    return doc.id;
  }

  // Mettre à jour un restaurant
  Future<void> updateRestaurant(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('restaurants').doc(id).update(data);
  }

  // Supprimer un restaurant
  Future<void> deleteRestaurant(String id) async {
    await _firestore.collection('restaurants').doc(id).delete();
  }

  // Rechercher des restaurants par ville
  Stream<List<RestaurantModel>> searchByCity(String city) {
    return _firestore
        .collection('restaurants')
        .where('city', isEqualTo: city)
        .where('isVisible', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RestaurantModel.fromFirestore(doc))
            .toList());
  }

  // Rechercher par type de cuisine
  Stream<List<RestaurantModel>> searchByCuisineType(String cuisineType) {
    return _firestore
        .collection('restaurants')
        .where('cuisineType', isEqualTo: cuisineType)
        .where('isVisible', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RestaurantModel.fromFirestore(doc))
            .toList());
  }
}
