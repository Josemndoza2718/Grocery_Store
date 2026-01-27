import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/repositories/local/new/new_product_repository.dart';

class CreateProductsUseCases {
  final NewProductRepository _repository;
  const CreateProductsUseCases(this._repository);

  Future<Result<void>> call(Product product) async {
    return await _repository.createProduct(product);
  }
}
