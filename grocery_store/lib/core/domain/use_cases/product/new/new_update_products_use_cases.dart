import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/repositories/local/new/new_product_repository.dart';

class NewUpdateProductsUseCases {
  final NewProductRepository _repository;

  NewUpdateProductsUseCases(this._repository);

  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);
  }
}
