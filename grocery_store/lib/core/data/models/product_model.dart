import 'package:grocery_store/core/domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.image,
    required super.categoryId,
    required super.category,
    required super.stockQuantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['imageUrl'],
      categoryId: json['categoryId'],
      category: json['category'],
      stockQuantity: json['stockQuantity'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': image,
      'categoryId': categoryId,
      'category': category,
      'stockQuantity': stockQuantity,
    };
  }

  toEntity(){
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      image: image,
      categoryId: categoryId,
      category: category,
      stockQuantity: stockQuantity,
    );
  }
}
