import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/store.dart';

abstract class StoreRepository {
  /// Real-time list of the stores owned by [ownerId] (including archived).
  Stream<List<Store>> watchOwnedStores(String ownerId);

  /// Real-time store document; emits `null` if it does not exist.
  Stream<Store?> watchStore(String storeId);

  /// Creates a store with a new id and returns it.
  Future<Result<Store>> createStore(Store store);

  Future<Result<void>> updateStore(Store store);

  /// Stores are never deleted: they are archived. Archiving atomically
  /// unlinks every employee of the store and deletes the pending invitations
  /// created by [ownerId]. Products, clients, carts and sales are kept.
  Future<Result<void>> archiveStore(String storeId, {required String ownerId});

  /// Makes an archived store available again (its employees are not
  /// re-linked: they need a new invitation).
  Future<Result<void>> restoreStore(String storeId);
}
