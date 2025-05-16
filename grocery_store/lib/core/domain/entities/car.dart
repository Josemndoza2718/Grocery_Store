import 'package:grocery_store/core/domain/entities/product.dart';

class Car {
  final int id;
  final List<Product> products;

  Car({
    required this.id,
    required this.products,
  });
}
