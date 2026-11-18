/// Per-user data stored in `users/{uid}` (synced across devices).
class UserProfile {
  /// Last store an owner worked in.
  final String? lastStoreId;

  const UserProfile({this.lastStoreId});
}

abstract class UserProfileRepository {
  Future<UserProfile> getProfile(String uid);

  Future<void> setLastStoreId(String uid, String storeId);
}
