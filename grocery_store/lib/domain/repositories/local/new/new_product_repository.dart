import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/product.dart';

/// Products of the active store (`stores/{storeId}/products`).
abstract class NewProductRepository {
  Future<Result<void>> createProduct(Product product);

  /// One-shot read (served from Firestore's offline cache when offline).
  Future<Result<List<Product>>> getProducts();
  Future<Result<void>> deleteProduct(String id);
  Future<Result<void>> updateProduct(Product product);

  /// Real-time list, newest first.
  Stream<List<Product>> getAllProductsStream();
}
