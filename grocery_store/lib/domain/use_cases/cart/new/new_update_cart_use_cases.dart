import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/repositories/local/new/new_cart_repository.dart';

class NewUpdateCartUseCases {
  const NewUpdateCartUseCases({required this.repository});

  final NewCartRepository repository;

  Future<Result<void>> call(Cart cart) async {
    return await repository.updateCart(cart);
  }
}
