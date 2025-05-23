
import 'package:grocery_store/core/data/repositories/local/car_client_repository_impl%20copy.dart';

class DeleteClientsUseCases {
  const DeleteClientsUseCases({required this.repository});

  final ClientRepositoryImpl repository;

  Future<void> deleteClient(int id) async {
    await repository.deleteClient(id);
  }
}
