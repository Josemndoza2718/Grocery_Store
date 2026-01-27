import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';

abstract class NewCartRepository {
  Stream<List<Cart>> getAllCartsStream({String? userId});
  Future<Result<void>> createCart(Cart cart);
  Future<Result<void>> updateCart(Cart cart);
  Future<Result<void>> deleteCart(String id);
  Future<Result<List<Cart>>> getLocalCarts();
}
