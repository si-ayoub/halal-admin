// lib/data/models/restaurant_model.dart
// HALAL ADMIN - Extension du modèle Restaurant pour algorithme de visibilité

import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? logoUrl;
  final String? phone;
  final String? website;
  final List<String> cuisineTypes;
  final bool isActive;
  
  // Plans & Abonnements
  final String plan; // 'free', 'premium', 'premium_plus'
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  
  // ALGORITHME DE VISIBILITÉ
  final int vCur; // Vues actuelles ce mois
  final int vMin; // Objectif mensuel de vues
  final double radius; // Rayon actuel en km
  final double radiusBase; // Rayon de base selon plan
  final double radiusMax; // Rayon maximum autorisé
  final double priorityBase; // P_base: 5 (premium+), 3 (premium), 1 (free)
  
  // Boost temporaire
  final DateTime? boostUntil; // Date fin du boost
  final double boostMultiplier; // 1.0 normal, 1.5 si boost actif
  
  // Méta-données algorithme
  final DateTime? lastRadiusUpdate; // Dernière mise à jour du rayon
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Analytics
  final int totalViews;
  final int monthlyViews;
  final double averageRating;
  final int reviewCount;

  RestaurantModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.logoUrl,
    this.phone,
    this.website,
    this.cuisineTypes = const [],
    this.isActive = true,
    
    // Plans
    this.plan = 'free',
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    
    // Algorithme (valeurs par défaut)
    this.vCur = 0,
    this.vMin = 10000, // Objectif par défaut
    this.radius = 2.0, // 2km par défaut
    this.radiusBase = 2.0,
    this.radiusMax = 10.0,
    this.priorityBase = 1.0, // Gratuit par défaut
    
    // Boost
    this.boostUntil,
    this.boostMultiplier = 1.0,
    
    // Méta
    this.lastRadiusUpdate,
    DateTime? createdAt,
    DateTime? updatedAt,
    
    // Analytics
    this.totalViews = 0,
    this.monthlyViews = 0,
    this.averageRating = 0.0,
    this.reviewCount = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Factory depuis Firestore
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      address: data['address'],
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'],
      logoUrl: data['logoUrl'],
      phone: data['phone'],
      website: data['website'],
      cuisineTypes: List<String>.from(data['cuisineTypes'] ?? []),
      isActive: data['isActive'] ?? true,
      
      // Plans
      plan: data['plan'] ?? 'free',
      subscriptionStartDate: data['subscriptionStartDate']?.toDate(),
      subscriptionEndDate: data['subscriptionEndDate']?.toDate(),
      
      // Algorithme
      vCur: data['vCur'] ?? 0,
      vMin: data['vMin'] ?? _getDefaultVMin(data['plan'] ?? 'free'),
      radius: (data['radius'] ?? 2.0).toDouble(),
      radiusBase: (data['radiusBase'] ?? 2.0).toDouble(),
      radiusMax: (data['radiusMax'] ?? 10.0).toDouble(),
      priorityBase: (data['priorityBase'] ?? 1.0).toDouble(),
      
      // Boost
      boostUntil: data['boostUntil']?.toDate(),
      boostMultiplier: (data['boostMultiplier'] ?? 1.0).toDouble(),
      
      // Méta
      lastRadiusUpdate: data['lastRadiusUpdate']?.toDate(),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      
      // Analytics
      totalViews: data['totalViews'] ?? 0,
      monthlyViews: data['monthlyViews'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  // Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'phone': phone,
      'website': website,
      'cuisineTypes': cuisineTypes,
      'isActive': isActive,
      
      // Plans
      'plan': plan,
      'subscriptionStartDate': subscriptionStartDate != null
          ? Timestamp.fromDate(subscriptionStartDate!)
          : null,
      'subscriptionEndDate': subscriptionEndDate != null
          ? Timestamp.fromDate(subscriptionEndDate!)
          : null,
      
      // Algorithme
      'vCur': vCur,
      'vMin': vMin,
      'radius': radius,
      'radiusBase': radiusBase,
      'radiusMax': radiusMax,
      'priorityBase': priorityBase,
      
      // Boost
      'boostUntil': boostUntil != null ? Timestamp.fromDate(boostUntil!) : null,
      'boostMultiplier': boostMultiplier,
      
      // Méta
      'lastRadiusUpdate': lastRadiusUpdate != null
          ? Timestamp.fromDate(lastRadiusUpdate!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      
      // Analytics
      'totalViews': totalViews,
      'monthlyViews': monthlyViews,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }

  // Copie avec modifications
  RestaurantModel copyWith({
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? logoUrl,
    String? phone,
    String? website,
    List<String>? cuisineTypes,
    bool? isActive,
    String? plan,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    int? vCur,
    int? vMin,
    double? radius,
    double? radiusBase,
    double? radiusMax,
    double? priorityBase,
    DateTime? boostUntil,
    double? boostMultiplier,
    DateTime? lastRadiusUpdate,
    DateTime? updatedAt,
    int? totalViews,
    int? monthlyViews,
    double? averageRating,
    int? reviewCount,
  }) {
    return RestaurantModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      isActive: isActive ?? this.isActive,
      plan: plan ?? this.plan,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      vCur: vCur ?? this.vCur,
      vMin: vMin ?? this.vMin,
      radius: radius ?? this.radius,
      radiusBase: radiusBase ?? this.radiusBase,
      radiusMax: radiusMax ?? this.radiusMax,
      priorityBase: priorityBase ?? this.priorityBase,
      boostUntil: boostUntil ?? this.boostUntil,
      boostMultiplier: boostMultiplier ?? this.boostMultiplier,
      lastRadiusUpdate: lastRadiusUpdate ?? this.lastRadiusUpdate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      totalViews: totalViews ?? this.totalViews,
      monthlyViews: monthlyViews ?? this.monthlyViews,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  // Helpers
  bool get isPremium => plan == 'premium' || plan == 'premium_plus';
  bool get isPremiumPlus => plan == 'premium_plus';
  bool get isFree => plan == 'free';
  
  bool get hasActiveBoost {
    if (boostUntil == null) return false;
    return DateTime.now().isBefore(boostUntil!);
  }
  
  bool get isSubscriptionActive {
    if (subscriptionEndDate == null) return false;
    return DateTime.now().isBefore(subscriptionEndDate!);
  }

  // Progression vers l'objectif (%)
  double get progressPercentage {
    if (vMin == 0) return 0.0;
    return (vCur / vMin * 100).clamp(0.0, 100.0);
  }

  // Nombre de vues restantes pour atteindre l'objectif
  int get viewsRemaining {
    final remaining = vMin - vCur;
    return remaining > 0 ? remaining : 0;
  }

  // Statut de performance
  String get performanceStatus {
    final progress = progressPercentage;
    if (progress >= 100) return 'excellent';
    if (progress >= 80) return 'good';
    if (progress >= 50) return 'average';
    return 'poor';
  }

  // Objectif par défaut selon le plan
  static int _getDefaultVMin(String plan) {
    switch (plan) {
      case 'premium_plus':
        return 100000; // 100K vues/mois
      case 'premium':
        return 80000; // 80K vues/mois
      case 'free':
      default:
        return 10000; // 10K vues/mois
    }
  }
}