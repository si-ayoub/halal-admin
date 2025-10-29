import 'enums.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final List<String> restaurantIds;
  final String? assignedPromoCode;
  final DateTime createdAt;
  
  UserModel({
    required this.id, required this.email, required this.displayName,
    required this.role, this.restaurantIds = const [], this.assignedPromoCode,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'email': email, 'displayName': displayName, 'role': role.name,
    'restaurantIds': restaurantIds, 'assignedPromoCode': assignedPromoCode,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '', email: json['email'] ?? '', displayName: json['displayName'] ?? '',
    role: UserRole.values.byName(json['role'] ?? 'restaurateur'),
    restaurantIds: List<String>.from(json['restaurantIds'] ?? []),
    assignedPromoCode: json['assignedPromoCode'],
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
  );
}
