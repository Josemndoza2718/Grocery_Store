import 'package:grocery_store/core/domain/entities/product.dart';

abstract class CarProductRepository {
  Future<void> addCarProduct(Product product);
  Future<void> updateCarProduct(Product product);
  Future<void> deleteCarProduct(int id);
  Future<Product?> getCarProductById(int id);
  Future<List<Product>> getAllCarProducts();
}