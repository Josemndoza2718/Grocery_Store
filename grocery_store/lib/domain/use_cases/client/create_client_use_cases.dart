import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/client.dart';
import 'package:grocery_store/domain/repositories/local/new/new_client_repository.dart';

class CreateClientUseCases {
  const CreateClientUseCases({required this.repository});

  final NewClientRepository repository;

  Future<Result<void>> call(Client client) {
    return repository.createClient(client);
  }
}
