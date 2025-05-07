import 'package:grocery_store/core/data/repositories/local/product_repository_impl.dart';
import 'package:grocery_store/core/domain/entities/product.dart';

class CreateProductsUseCases {
  const CreateProductsUseCases({required this.repository});

  final ProductRepositoryImpl repository;

  Future<void> call(Product product) async {
    await repository.addProduct(product);
  }

  
}