import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';

abstract class PaymentRepository {
  Future<Result<void>> processPayment(Cart cart);
}

class ProcessPaymentUseCase {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  Future<Result<void>> call(Cart cart) {
    return repository.processPayment(cart);
  }
}
