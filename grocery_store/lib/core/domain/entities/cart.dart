import 'package:grocery_store/core/domain/entities/product.dart';

class Cart {
  final int id;
  final int ownerId;
  final String? ownerCarName;
  String status;
  int payPart;
  final List<Product> products;

  Cart({
    required this.id,
    required this.ownerId,
    this.ownerCarName,
    this.status = 'pending',
    this.payPart = 0,
    required this.products,
  });
}
