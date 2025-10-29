import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionStatus { active, inactive, canceled }

class SubscriptionModel {
  final String id;
  final String restaurantId;
  final String plan;
  final SubscriptionStatus status;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  SubscriptionModel({
    required this.id,
    required this.restaurantId,
    required this.plan,
    required this.status,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      plan: data['plan'] ?? 'free',
      status: _parseStatus(data['status']),
      amount: (data['amount'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'plan': plan,
      'status': status.name,
      'amount': amount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static SubscriptionStatus _parseStatus(String? status) {
    switch (status) {
      case 'active': return SubscriptionStatus.active;
      case 'canceled': return SubscriptionStatus.canceled;
      default: return SubscriptionStatus.inactive;
    }
  }

  bool get isActive => status == SubscriptionStatus.active && DateTime.now().isBefore(endDate);
}
