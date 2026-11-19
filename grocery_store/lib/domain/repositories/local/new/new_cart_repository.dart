import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';

/// Active carts of the store (`stores/{storeId}/carts`), shared by all its
/// members.
abstract class NewCartRepository {
  Stream<List<Cart>> getAllCartsStream();
  Future<Result<void>> createCart(Cart cart);
  Future<Result<void>> updateCart(Cart cart);
  Future<Result<void>> deleteCart(String id);
}
