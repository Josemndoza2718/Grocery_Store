import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/repositories/local/new/new_product_repository.dart';

class NewGetProductsUseCases {
  final NewProductRepository _repository;

  const NewGetProductsUseCases(this._repository);

  Future<Result<List<Product>>> call() async {
    return await _repository.getLocalProducts();
  }

  Stream<List<Product>> callStream({String? userId}) {
    return _repository.getAllProductsStream(userId: userId);
  }
}
