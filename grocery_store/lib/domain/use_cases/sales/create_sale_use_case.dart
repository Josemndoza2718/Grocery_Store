import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/repositories/local/new/sales_history_repository.dart';

class CreateSaleUseCase {
  final SalesHistoryRepository repository;

  CreateSaleUseCase(this.repository);

  Future<Result<void>> call(Cart cart) {
    return repository.createSale(cart);
  }
}
