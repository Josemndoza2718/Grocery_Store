import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/repositories/local/new/sales_history_repository.dart';

class GetSalesUseCase {
  final SalesHistoryRepository repository;

  GetSalesUseCase(this.repository);

  Stream<List<Cart>> callStream({String? userId}) {
    return repository.getSalesStream(userId: userId);
  }
}
