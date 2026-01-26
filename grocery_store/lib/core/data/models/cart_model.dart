import 'package:grocery_store/core/data/models/product_model.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';

class CartModel extends Cart {
  CartModel({
    required super.id,
    required super.userId,
    required super.ownerId,
    super.ownerCarName,
    super.status,
    required super.products,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      userId: json['userId'] ?? '',
      ownerId: json['owner_id'],
      ownerCarName: json['owner_car_name'],
      status: json['status'],
      products: (json['products'] as List)
          .map((item) => ProductModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'owner_id': ownerId,
      'owner_car_name': ownerCarName,
      'status': status,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }

    toEntity(){
    return Cart(
      id: id,
      userId: userId,
      ownerId: ownerId,
      ownerCarName: ownerCarName,
      status: status,
      products: products,
    );
  }
}
