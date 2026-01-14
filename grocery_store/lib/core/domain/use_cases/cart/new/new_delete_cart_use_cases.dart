import 'package:grocery_store/core/domain/repositories/local/new/new_cart_repository.dart';

class NewDeleteCartUseCases {
  const NewDeleteCartUseCases({required this.repository});

  final NewCartRepository repository;

  Future<void> call(String id) async {
    await repository.deleteCart(id);
  }
}
