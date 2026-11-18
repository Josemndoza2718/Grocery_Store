import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/repositories/local/new/new_client_repository.dart';

class DeleteClientsUseCases {
  const DeleteClientsUseCases({required this.repository});

  final NewClientRepository repository;

  Future<Result<void>> deleteClient(String id) {
    return repository.deleteClient(id);
  }
}
