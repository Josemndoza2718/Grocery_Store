import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/entities/product.dart';

abstract class CashProductRepository {
  Future<void> addCashProduct(Cart car);
  Future<void> updateCashProduct(Product product);
  Future<void> deleteCashProduct(int id);
  Future<Product?> getCashProductById(int id);
  Future<List<Product>> getAllCashProducts();
}