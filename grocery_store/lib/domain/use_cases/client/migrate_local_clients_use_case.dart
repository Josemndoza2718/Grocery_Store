import 'package:grocery_store/domain/repositories/local/client_repository.dart';
import 'package:grocery_store/domain/repositories/local/new/new_client_repository.dart';

/// One-time migration of the clients stored only on the device (legacy
/// Sembast store) to Firestore, owned by the user that is logged in.
///
/// The client id is preserved so existing carts (which reference the client
/// through `ownerId`) stay linked. Each client is removed from the local store
/// only after it was written to Firestore, so the migration is safe to retry:
/// if something fails, the remaining clients are migrated on the next login.
class MigrateLocalClientsUseCase {
  const MigrateLocalClientsUseCase({
    required this.legacyRepository,
    required this.repository,
  });

  final ClientRepository legacyRepository;
  final NewClientRepository repository;

  /// Returns the number of clients migrated.
  Future<int> call({required String userId}) async {
    if (userId.isEmpty) return 0;

    final localClients = await legacyRepository.getAllClients();
    var migrated = 0;

    for (final client in localClients) {
      final result = await repository.createClient(
        client.copyWith(userId: userId),
      );
      if (result.isSuccess) {
        await legacyRepository.deleteClient(client.id);
        migrated++;
      }
    }
    return migrated;
  }
}
