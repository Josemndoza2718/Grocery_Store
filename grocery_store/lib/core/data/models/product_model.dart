import 'package:grocery_store/core/domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.image,
    required super.idStock,
    required super.stockQuantity,
    required super.quantityToBuy,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['imageUrl'],
      idStock: json['idStock'],
      stockQuantity: json['stockQuantity'],
      quantityToBuy: json['quantity'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': image,
      'idStock': idStock,
      'stockQuantity': stockQuantity,
      'quantity': quantityToBuy,
    };
  }

  toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      image: image,
      idStock: idStock,
      stockQuantity: stockQuantity,
      quantityToBuy: quantityToBuy,
    );
  }
}
