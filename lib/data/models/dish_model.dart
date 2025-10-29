class DishModel {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final String? photoUrl;
  
  DishModel({required this.id, required this.name, this.description, this.price, this.photoUrl});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'description': description, 'price': price, 'photoUrl': photoUrl};

  factory DishModel.fromJson(Map<String, dynamic> json) => DishModel(
    id: json['id'] ?? '', name: json['name'] ?? '', description: json['description'], 
    price: json['price']?.toDouble(), photoUrl: json['photoUrl'],
  );
}
