import 'package:grocery_store/core/data/repositories/local/car_client_repository_impl.dart';
import 'package:grocery_store/core/domain/entities/client.dart';

class CreateClientUseCases {
  const CreateClientUseCases({required this.repository});

  final ClientRepositoryImpl repository;

  Future<void> call(Client client) async {
    await repository.addClient(client);
  }

  
}