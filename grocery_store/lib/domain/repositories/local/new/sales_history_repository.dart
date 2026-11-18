import 'package:grocery_store/domain/entities/cart.dart';

/// Sales of the store (`stores/{storeId}/sales`). Sales are created by the
/// checkout transaction (see PaymentRepository) and are immutable.
abstract class SalesHistoryRepository {
  /// Real-time sales, newest first. With [soldBy], only the sales charged by
  /// that user (required for employees by the security rules).
  Stream<List<Cart>> getSalesStream({String? soldBy});
}
