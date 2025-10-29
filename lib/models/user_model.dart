import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  ceo,
  commercial,
  influencer,
  restaurantOwner,
  user,
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final String? promoCode;
  final String? restaurantId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.promoCode,
    this.restaurantId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      role: _parseRole(data['role']),
      promoCode: data['promoCode'],
      restaurantId: data['restaurantId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'promoCode': promoCode,
      'restaurantId': restaurantId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'ceo': return UserRole.ceo;
      case 'commercial': return UserRole.commercial;
      case 'influencer': return UserRole.influencer;
      case 'restaurantOwner': return UserRole.restaurantOwner;
      default: return UserRole.user;
    }
  }

  bool get isCEO => role == UserRole.ceo;
  bool get isCommercial => role == UserRole.commercial;
  bool get canAccessBoost => isCEO || isCommercial;
  bool get canAccessAdmin => role == UserRole.restaurantOwner;
}
