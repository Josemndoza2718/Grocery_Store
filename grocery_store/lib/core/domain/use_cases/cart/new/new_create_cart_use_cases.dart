import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/repositories/local/new/new_cart_repository.dart';

class NewCreateCartUseCases {
  const NewCreateCartUseCases({required this.repository});

  final NewCartRepository repository;

  Future<void> call(Cart cart) async {
    await repository.createCart(cart);
  }
}
