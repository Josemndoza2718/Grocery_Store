import 'package:grocery_store/core/domain/repositories/local/new/new_product_repository.dart';

class NewDeleteProductsUseCases {
  final NewProductRepository _repository;

  NewDeleteProductsUseCases(this._repository);

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
  }
}
