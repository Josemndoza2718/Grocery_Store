
import 'package:grocery_store/core/data/repositories/local/product_repository_impl.dart';

class DeleteProductsUseCases {
  const DeleteProductsUseCases({required this.repository});

  final ProductRepositoryImpl repository;

  Future<void> deleteProduct(int id) async {
    await repository.deleteProduct(id);
  }
}
