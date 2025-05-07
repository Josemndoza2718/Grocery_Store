import 'package:grocery_store/core/data/repositories/local/product_repository_impl.dart';
import 'package:grocery_store/core/domain/entities/product.dart';

class GetProductsUseCases {
  const GetProductsUseCases({required this.repository});

  final ProductRepositoryImpl repository;

  Future<List<Product>> call() async {
    return await repository.getAllProducts();
  }

  

}
