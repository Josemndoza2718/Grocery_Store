import 'package:grocery_store/core/data/repositories/local/car_product_repository_impl.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';

class CreateCarProductsUseCases {
  const CreateCarProductsUseCases({required this.repository});

  final CarProductRepositoryImpl repository;

  Future<void> call(Cart cart) async {
    await repository.addCarProduct(cart);
  }

  
}