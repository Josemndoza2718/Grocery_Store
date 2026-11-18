import 'package:grocery_store/domain/entities/client.dart';
import 'package:grocery_store/domain/repositories/local/new/new_client_repository.dart';

class GetClientsUseCases {
  const GetClientsUseCases({required this.repository});

  final NewClientRepository repository;

  /// Real-time list of the clients owned by [userId].
  Stream<List<Client>> callStream({required String userId}) {
    return repository.getClientsStream(userId: userId);
  }
}
