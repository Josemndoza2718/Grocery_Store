import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/repositories/local/new/new_cart_repository.dart';

class NewDeleteCartUseCases {
  const NewDeleteCartUseCases({required this.repository});

  final NewCartRepository repository;

  Future<Result<void>> call(String id) async {
    return await repository.deleteCart(id);
  }
}
