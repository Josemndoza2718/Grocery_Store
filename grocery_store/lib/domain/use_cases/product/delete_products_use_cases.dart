import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/repositories/local/new/new_product_repository.dart';

class NewDeleteProductsUseCases {
  final NewProductRepository _repository;

  NewDeleteProductsUseCases(this._repository);

  Future<Result<void>> deleteProduct(String id) async {
    return await _repository.deleteProduct(id);
  }
}
