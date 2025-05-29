
import 'package:grocery_store/core/data/repositories/local/cash_product_repository_impl.dart';

class DeleteCashProductsUseCases {
  const DeleteCashProductsUseCases({required this.repository});

  final CashProductRepositoryImpl repository;

  Future<void> deleteCashProduct(int id) async {
    await repository.deleteCashProduct(id);
  }
}
