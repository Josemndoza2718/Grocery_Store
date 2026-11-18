import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/store.dart';

abstract class StoreRepository {
  /// Real-time list of the stores owned by [ownerId] (including archived).
  Stream<List<Store>> watchOwnedStores(String ownerId);

  /// Real-time store document; emits `null` if it does not exist.
  Stream<Store?> watchStore(String storeId);

  /// Creates a store and returns it. Uses [id] when given (deterministic id,
  /// e.g. for the migration), otherwise a new random id.
  Future<Result<Store>> createStore(Store store, {String? id});

  Future<Result<void>> updateStore(Store store);

  /// Stores are never deleted: they are archived.
  Future<Result<void>> archiveStore(String storeId);
}
