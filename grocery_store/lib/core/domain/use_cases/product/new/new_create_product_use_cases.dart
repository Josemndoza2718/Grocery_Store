import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/repositories/local/new/new_product_repository.dart';

class NewCreateProductsUseCases {
  final NewProductRepository _repository;
  const NewCreateProductsUseCases(this._repository);

  Future<void> call(Product product) async {
    await _repository.createProduct(product);
  }
}
