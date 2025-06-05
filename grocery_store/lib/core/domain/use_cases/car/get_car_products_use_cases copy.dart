import 'package:grocery_store/core/data/repositories/local/car_product_repository_impl.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/product.dart';

class GetCarProductsUseCases {
  const GetCarProductsUseCases({required this.repository});

  final CarProductRepositoryImpl repository;

  Future<List<Cart>> call() async {
    return await repository.getAllCarProducts();
  }

  

}
