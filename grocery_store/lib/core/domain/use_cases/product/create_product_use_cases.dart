import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/repositories/local/product_repository.dart';

class CreateProductsUseCases {
  const CreateProductsUseCases({required this.repository});

  final ProductRepository repository;

  Future<void> call(Product product) async {
    await repository.addProduct(product);
  }
}
