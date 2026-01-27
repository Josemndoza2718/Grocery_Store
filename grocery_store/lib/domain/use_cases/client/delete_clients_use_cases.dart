
import 'package:grocery_store/data/repositories/local/car_client_repository_impl.dart';

class DeleteClientsUseCases {
  const DeleteClientsUseCases({required this.repository});

  final ClientRepositoryImpl repository;

  Future<void> deleteClient(int id) async {
    await repository.deleteClient(id);
  }
}
