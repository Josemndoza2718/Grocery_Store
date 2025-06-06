import 'package:grocery_store/core/domain/entities/product.dart';

class Cart {
  final int id;
  final int ownerId;
  final String? ownerCarName;
  final String status;
  final List<Product> products;

  Cart({
    required this.id,
    required this.ownerId,
    this.ownerCarName,
    this.status = 'pending',
    required this.products,
  });
}
