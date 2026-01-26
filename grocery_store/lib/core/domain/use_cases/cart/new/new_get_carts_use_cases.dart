import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/repositories/local/new/new_cart_repository.dart';

class NewGetCartsUseCases {
  const NewGetCartsUseCases({required this.repository});

  final NewCartRepository repository;

  // Para obtener el stream en tiempo real
  Stream<List<Cart>> callStream({String? userId}) {
    return repository.getAllCartsStream(userId: userId);
  }

  // Para obtener caché local (sin conexión)
  Future<List<Cart>> call() async {
    return await repository.getLocalCarts();
  }
}
