import 'package:grocery_store/data/repositories/local/cash_product_repository_impl.dart';
import 'package:grocery_store/domain/entities/product.dart';

class GetCashProductsUseCases {
  const GetCashProductsUseCases({required this.repository});

  final CashProductRepositoryImpl repository;

  Future<List<Product>> call() async {
    return await repository.getAllCashProducts();
  }

  

}
