import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/client.dart';

/// Clients of the store, persisted in Firestore (`clients` collection) and
/// isolated per Firebase Auth user through the `userId` field.
abstract class NewClientRepository {
  /// Real-time list of the clients owned by [userId], ordered by name.
  Stream<List<Client>> getClientsStream({required String userId});

  /// Creates (or overwrites) a client. The document id is [Client.id], so
  /// writing the same client twice is idempotent.
  Future<Result<void>> createClient(Client client);

  Future<Result<void>> updateClient(Client client);

  Future<Result<void>> deleteClient(String id);
}
