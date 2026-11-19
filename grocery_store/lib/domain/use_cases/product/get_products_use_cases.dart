import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/repositories/local/new/new_product_repository.dart';

class NewGetProductsUseCases {
  final NewProductRepository _repository;

  const NewGetProductsUseCases(this._repository);

  Future<Result<List<Product>>> call() => _repository.getProducts();

  Stream<List<Product>> callStream() => _repository.getAllProductsStream();
}
