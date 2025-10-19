import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/repositories/local/new/new_product_repository.dart';

class NewGetProductsUseCases {
  final NewProductRepository _repository;

  const NewGetProductsUseCases(this._repository);

  Future<List<Product>> call() async {
    var list = await _repository.getLocalProducts();
    return list;
  }
}
