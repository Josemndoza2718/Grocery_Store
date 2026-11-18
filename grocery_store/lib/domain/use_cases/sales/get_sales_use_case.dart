import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/repositories/local/new/sales_history_repository.dart';

class GetSalesUseCase {
  final SalesHistoryRepository repository;

  GetSalesUseCase(this.repository);

  /// All sales of the store, or only those charged by [soldBy].
  Stream<List<Cart>> callStream({String? soldBy}) =>
      repository.getSalesStream(soldBy: soldBy);
}
