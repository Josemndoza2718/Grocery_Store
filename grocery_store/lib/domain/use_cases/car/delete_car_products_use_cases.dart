
import 'package:grocery_store/data/repositories/local/car_product_repository_impl.dart';

class DeleteCarProductsUseCases {
  const DeleteCarProductsUseCases({required this.repository});

  final CartRepositoryImpl repository;

  Future<void> deleteCarProduct(int id) async {
    await repository.deleteCarProduct(id);
  }
}
