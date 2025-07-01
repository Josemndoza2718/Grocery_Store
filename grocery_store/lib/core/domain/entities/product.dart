class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int categoryId;
  final String category;
  final int? idStock;
  final double stockQuantity;
  double quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.category,
    required this.stockQuantity,
    this.idStock,
    this.quantity = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': image,
      'categoryId': categoryId,
      'category': category,
      'idStock': idStock,
      'stockQuantity': stockQuantity,
      'quantity': quantity,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      image: json['imageUrl'],
      categoryId: json['categoryId'],
      category: json['category'],
      idStock: json['idStock'],
      stockQuantity: json['stockQuantity'],
      quantity: json['quantity'] ?? 0,
    );
  }

}
