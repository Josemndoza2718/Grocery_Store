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
    required super.idStock,
    required super.stockQuantity,
    required super.quantity,
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
      idStock: json['idStock'],
      stockQuantity: json['stockQuantity'].toDouble(),
      quantity: json['quantity'] ?? 0.0,
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
      'idStock': idStock,
      'stockQuantity': stockQuantity,
      'quantity': quantity,
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
      idStock: idStock,
      stockQuantity: stockQuantity,
      quantity: quantity,
    );
  }
}
