import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/client.dart';

/// Clients of the active store (`stores/{storeId}/clients`), shared by all
/// its members.
abstract class NewClientRepository {
  /// Real-time list of the clients, ordered by name.
  Stream<List<Client>> getClientsStream();

  /// Creates (or overwrites) a client. The document id is [Client.id], so
  /// writing the same client twice is idempotent.
  Future<Result<void>> createClient(Client client);

  Future<Result<void>> updateClient(Client client);

  Future<Result<void>> deleteClient(String id);
}
