import 'package:grocery_store/data/repositories/local/car_product_repository_impl.dart';
import 'package:grocery_store/domain/entities/cart.dart';

class CreateCarProductsUseCases {
  const CreateCarProductsUseCases({required this.repository});

  final CartRepositoryImpl repository;

  Future<void> call(Cart cart) async {
    await repository.addCarProduct(cart);
  }

  
}