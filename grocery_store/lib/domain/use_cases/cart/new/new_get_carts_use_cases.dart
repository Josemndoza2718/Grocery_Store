import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/repositories/local/new/new_cart_repository.dart';

class NewGetCartsUseCases {
  const NewGetCartsUseCases({required this.repository});

  final NewCartRepository repository;

  /// Real-time carts of the store.
  Stream<List<Cart>> callStream() => repository.getAllCartsStream();
}
