/// Number of documents copied by the migration, per collection.
class MigrationReport {
  final int products;
  final int clients;
  final int carts;
  final int sales;

  const MigrationReport({
    this.products = 0,
    this.clients = 0,
    this.carts = 0,
    this.sales = 0,
  });

  int get total => products + clients + carts + sales;
}

/// One-time copy of the data of the old per-user model (top-level
/// `products`, `clients`, `carts`, `sales-history` filtered by `userId`, plus
/// clients stored only on the device) into a store.
///
/// The originals are NOT deleted (they stay as a backup until phase 5 of
/// docs/PLAN_MULTITIENDA.md). Document ids are preserved so carts keep
/// pointing to their clients, and documents that already exist in the store
/// are skipped, so the migration can be safely retried.
abstract class LegacyMigrationRepository {
  /// Whether [uid] has any data in the old model.
  Future<bool> hasLegacyData(String uid);

  /// Copies the legacy data of [uid] into `stores/{storeId}`. Sales are
  /// attributed to [uid] / [userName] as seller. Throws on failure.
  Future<MigrationReport> migrate({
    required String uid,
    required String storeId,
    required String userName,
  });
}
