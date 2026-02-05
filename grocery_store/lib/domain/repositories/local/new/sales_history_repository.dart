import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';

abstract class SalesHistoryRepository {
  /// Saves a paid cart to sales-history
  Future<Result<void>> createSale(Cart cart);

  /// Streams all sales for a specific user
  Stream<List<Cart>> getSalesStream({String? userId});

  /// Gets sales from local storage (offline)
  Future<Result<List<Cart>>> getLocalSales();
}
