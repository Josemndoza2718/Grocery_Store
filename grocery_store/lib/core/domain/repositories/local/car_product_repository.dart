import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/product.dart';

abstract class CarProductRepository {
  Future<void> addCarProduct(Cart cart);
  Future<void> updateCarProduct(Cart product);
  Future<void> deleteCarProduct(int id);
  Future<Product?> getCarProductById(int id);
  Future<List<Cart>> getAllCarProducts();
}