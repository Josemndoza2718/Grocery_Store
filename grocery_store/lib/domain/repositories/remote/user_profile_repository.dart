/// Per-user data stored in `users/{uid}` (synced across devices).
class UserProfile {
  /// Last store an owner worked in.
  final String? lastStoreId;

  /// When the legacy per-user data was migrated into a store (or checked and
  /// found empty). `null` means the migration has not run yet.
  final DateTime? migratedAt;

  const UserProfile({this.lastStoreId, this.migratedAt});

  bool get isMigrated => migratedAt != null;
}

abstract class UserProfileRepository {
  Future<UserProfile> getProfile(String uid);

  Future<void> setLastStoreId(String uid, String storeId);

  /// Records that the legacy data of [uid] was migrated (into [storeId], if
  /// there was anything to migrate).
  Future<void> markMigrated(String uid, {String? storeId});
}
