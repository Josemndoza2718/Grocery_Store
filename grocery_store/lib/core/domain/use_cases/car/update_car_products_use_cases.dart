import 'package:grocery_store/core/data/repositories/local/car_product_repository_impl.dart';
import 'package:grocery_store/core/domain/entities/product.dart';

class UpdateCarProductsUseCases {
  const UpdateCarProductsUseCases({required this.repository});

  final CarProductRepositoryImpl repository;

 
  Future<void> updateProduct(Product product) async {
    await repository.updateCarProduct(product);
  }
}