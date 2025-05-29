import 'package:grocery_store/core/domain/entities/check.dart';
import 'package:grocery_store/core/domain/entities/product.dart';

abstract class CashProductRepository {
  Future<void> addCashProduct(Check car);
  Future<void> updateCashProduct(Product product);
  Future<void> deleteCashProduct(int id);
  Future<Product?> getCashProductById(int id);
  Future<List<Product>> getAllCashProducts();
}