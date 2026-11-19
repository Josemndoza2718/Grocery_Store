import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';

abstract class PaymentRepository {
  /// Charges [cart] atomically: validates and discounts the real stock,
  /// stores [sale] (the cart with the checkout data) in the store's sales and
  /// deletes the active cart.
  Future<Result<void>> processPayment(Cart cart, Cart sale);
}

class ProcessPaymentUseCase {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  Future<Result<void>> call(Cart cart, Cart sale) =>
      repository.processPayment(cart, sale);
}
