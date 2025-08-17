import 'package:grocery_store/core/data/repositories/local/product_repository_impl.dart';

class SendProductFirebaseUseCases {
  const SendProductFirebaseUseCases({required this.repository});

  final ProductRepositoryImpl repository;

  Future<void> call() async {
    await repository.sendProductsToFirebase();
  }
}
