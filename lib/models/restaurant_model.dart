import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String ownerId;
  final String email;
  final String phone;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String description;
  final String cuisineType;
  final List<String> photos;
  final bool isVisible;
  final String subscriptionPlan;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.cuisineType,
    required this.photos,
    required this.isVisible,
    required this.subscriptionPlan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      cuisineType: data['cuisineType'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      isVisible: data['isVisible'] ?? false,
      subscriptionPlan: data['subscriptionPlan'] ?? 'free',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerId': ownerId,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'cuisineType': cuisineType,
      'photos': photos,
      'isVisible': isVisible,
      'subscriptionPlan': subscriptionPlan,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
