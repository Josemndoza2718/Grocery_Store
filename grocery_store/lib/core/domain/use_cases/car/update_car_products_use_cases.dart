import 'package:grocery_store/core/data/repositories/local/car_product_repository_impl.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';

class UpdateCarProductsUseCases {
  const UpdateCarProductsUseCases({required this.repository});

  final CartRepositoryImpl repository;

 
  Future<void> updateProduct(Cart cart) async {
    await repository.updateCarProduct(cart);
  }
}