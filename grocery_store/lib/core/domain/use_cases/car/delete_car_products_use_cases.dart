
import 'package:grocery_store/core/data/repositories/local/car_product_repository_impl.dart';

class DeleteCarProductsUseCases {
  const DeleteCarProductsUseCases({required this.repository});

  final CarProductRepositoryImpl repository;

  Future<void> deleteCarProduct(int id) async {
    await repository.deleteCarProduct(id);
  }
}
