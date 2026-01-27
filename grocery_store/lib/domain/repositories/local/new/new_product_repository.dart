import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/product.dart';

abstract class NewProductRepository {
  Future<Result<void>> createProduct(Product product);
  Future<Result<List<Product>>> getLocalProducts();
  Future<Result<void>> deleteProduct(String id);
  Future<Result<void>> updateProduct(Product product);
  Stream<List<Product>> getAllProductsStream({String? userId});
}
