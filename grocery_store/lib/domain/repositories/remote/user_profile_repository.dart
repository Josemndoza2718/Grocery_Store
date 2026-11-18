/// Per-user preferences stored in `users/{uid}` (synced across devices).
abstract class UserProfileRepository {
  /// Last store an owner worked in, or `null`.
  Future<String?> getLastStoreId(String uid);

  Future<void> setLastStoreId(String uid, String storeId);
}
