class Product {
  final String id;
  final String userId; // Firebase Auth UID for user isolation
  final String name;
  final String description;
  final double price;
  final String image;
  final String idStock;
  final int stockQuantity;
  int quantityToBuy;
  final DateTime createdAt;

  Product({
    required this.id,
    this.userId = '',
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.stockQuantity,
    required this.idStock,
    this.quantityToBuy = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': image,
      'idStock': idStock,
      'stockQuantity': stockQuantity,
      'quantity': quantityToBuy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      userId: json['userId'] ?? '',
      name: json['name'],
      description: json['description'],
      price: json['price'],
      image: json['imageUrl'],
      idStock: json['idStock'],
      stockQuantity: json['stockQuantity'],
      quantityToBuy: json['quantity'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Product copyWith({
    String? id,
    String? userId,
    String? image,
    String? name,
    String? description,
    double? price,
    String? idStock,
    int? stockQuantity,
    int? quantity,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      image: image ?? this.image,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      idStock: idStock ?? this.idStock,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        quantityToBuy: quantity ?? this.quantityToBuy,
        createdAt: createdAt ?? this.createdAt,
      );
  }
}
