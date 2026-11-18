/// Role of the logged-in user inside the active store.
enum StoreRole { owner, employee }

/// The active working context: who is logged in, in which store and with
/// which role. View models and repositories of a session are created for one
/// [AppSession] and recreated when it changes.
class AppSession {
  final String uid;
  final String storeId;
  final StoreRole role;

  const AppSession({
    required this.uid,
    required this.storeId,
    required this.role,
  });

  bool get isOwner => role == StoreRole.owner;
  bool get isEmployee => role == StoreRole.employee;

  // Permissions (see docs/PLAN_MULTITIENDA.md §1). The Firestore rules enforce
  // them too; these getters only decide what the UI shows.
  bool get canManageProducts => isOwner;
  bool get canManageStoreSettings => isOwner;
  bool get canManageEmployees => isOwner;
  bool get canSeeAllSales => isOwner;
  bool get canSwitchStore => isOwner;

  /// Unique key of the session, used to recreate the session providers.
  String get key => '$uid-$storeId';
}
