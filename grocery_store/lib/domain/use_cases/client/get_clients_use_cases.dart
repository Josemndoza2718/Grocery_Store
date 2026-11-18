import 'package:grocery_store/domain/entities/client.dart';
import 'package:grocery_store/domain/repositories/local/new/new_client_repository.dart';

class GetClientsUseCases {
  const GetClientsUseCases({required this.repository});

  final NewClientRepository repository;

  /// Real-time list of the clients of the store.
  Stream<List<Client>> callStream() => repository.getClientsStream();
}
