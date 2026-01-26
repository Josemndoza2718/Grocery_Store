import 'package:grocery_store/core/domain/entities/cart.dart';

abstract class NewCartRepository {
  Stream<List<Cart>> getAllCartsStream({String? userId});
  Future<void> createCart(Cart cart);
  Future<void> updateCart(Cart cart);
  Future<void> deleteCart(String id);
  Future<List<Cart>> getLocalCarts();
}
