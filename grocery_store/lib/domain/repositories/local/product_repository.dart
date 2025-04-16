import 'package:grocery_store/domain/entities/product.dart';

abstract class ProductRepository {
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);
  Future<Product?> getProductById(int id);
  Future<List<Product>> getAllProducts();
}