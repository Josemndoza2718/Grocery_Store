import 'package:grocery_store/core/data/repositories/local/car_client_repository_impl.dart';
import 'package:grocery_store/core/domain/entities/client.dart';

class UpdateClientsUseCases {
  const UpdateClientsUseCases({required this.repository});

  final ClientRepositoryImpl repository;

 
  Future<void> updateClient(Client client) async {
    await repository.updateClient(client);
  }
}