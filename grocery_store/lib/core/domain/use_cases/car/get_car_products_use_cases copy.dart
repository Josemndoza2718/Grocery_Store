import 'package:grocery_store/core/data/repositories/local/car_product_repository_impl.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';

class GetAllCartsUseCases {
  const GetAllCartsUseCases({required this.repository});

  final CartRepositoryImpl repository;

  Future<List<Cart>> call() async {
    return await repository.getAllCarProducts();
  }

  

}
