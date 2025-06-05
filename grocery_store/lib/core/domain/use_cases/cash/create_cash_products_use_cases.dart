import 'package:grocery_store/core/data/repositories/local/cash_product_repository_impl.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';

class CreateCashProductsUseCases {
  const CreateCashProductsUseCases({required this.repository});

  final CashProductRepositoryImpl repository;

  Future<void> call(Cart car) async {
    await repository.addCashProduct(car);
  }
}
