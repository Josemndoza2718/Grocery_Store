import 'package:grocery_store/core/domain/entities/product.dart';

abstract class NewProductRepository {
  Future<void> createProduct(Product product);
  Future<List<Product>> getLocalProducts();
}
