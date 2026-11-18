import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grocery_store/core/errors/failure.dart';
import 'package:grocery_store/domain/entities/app_session.dart';
import 'package:grocery_store/domain/entities/employee.dart';
import 'package:grocery_store/domain/entities/invitation.dart';
import 'package:grocery_store/domain/entities/store.dart';
import 'package:grocery_store/domain/repositories/remote/employee_repository.dart';
import 'package:grocery_store/domain/repositories/remote/invitation_repository.dart';
import 'package:grocery_store/domain/repositories/remote/legacy_migration_repository.dart';
import 'package:grocery_store/domain/repositories/remote/store_repository.dart';
import 'package:grocery_store/domain/repositories/remote/user_profile_repository.dart';

enum SessionStatus {
  /// Still resolving the user's stores / employee link.
  loading,

  /// Copying the data of the old per-user model into the user's store.
  migrating,

  /// The user has no store to work in (must create one or join with a code).
  noStore,

  /// The user owns several stores and must choose one.
  pickStore,

  /// A store is active: [SessionController.session] is available.
  ready,

  /// The store data could not be loaded (e.g. permissions, network).
  error,
}

/// Store settings stored on the device before multi-store (IVA, rate). They
/// become the initial settings of the stores created on this device.
typedef DeviceStoreSettings = ({double iva, double exchangeRate});

/// Resolves, for the logged-in user [uid], which store they work in and with
/// which role. One instance per authenticated user (recreated on login).
///
/// Rules:
/// - If `employees/{uid}` exists → employee of that store (it has priority).
/// - Otherwise → owner. Before entering, the data of the old per-user model
///   is migrated once (see [LegacyMigrationRepository]). Then the owner
///   auto-enters the selected / last used / only store; with several stores
///   and no valid choice → [SessionStatus.pickStore].
class SessionController extends ChangeNotifier {
  SessionController({
    required this.uid,
    this.userName = '',
    this.userEmail = '',
    required StoreRepository storeRepository,
    required EmployeeRepository employeeRepository,
    required UserProfileRepository userProfileRepository,
    LegacyMigrationRepository? legacyMigrationRepository,
    InvitationRepository? invitationRepository,
    Future<DeviceStoreSettings> Function()? loadDeviceSettings,
    DateTime Function()? clock,
  })  : _stores = storeRepository,
        _invitations = invitationRepository,
        _clock = clock ?? DateTime.now,
        _employees = employeeRepository,
        _profiles = userProfileRepository,
        _migration = legacyMigrationRepository,
        _loadDeviceSettings = loadDeviceSettings {
    _start();
  }

  final String uid;

  /// Display name of the user (seller name in sales).
  final String userName;

  /// Email of the user (shown to the owner in the employees list).
  final String userEmail;

  final InvitationRepository? _invitations;
  final DateTime Function() _clock;

  final StoreRepository _stores;
  final EmployeeRepository _employees;
  final UserProfileRepository _profiles;
  final LegacyMigrationRepository? _migration;
  final Future<DeviceStoreSettings> Function()? _loadDeviceSettings;

  /// Id of the store created by the migration when the user had none.
  String get legacyStoreId => 'legacy_$uid';

  StreamSubscription<Employee?>? _employeeSub;
  StreamSubscription<List<Store>>? _ownedStoresSub;
  StreamSubscription<Store?>? _employeeStoreSub;

  Employee? _employee;
  bool _employeeLoaded = false;

  Store? _employeeStore;
  bool _employeeStoreLoaded = false;

  List<Store> _ownedStores = [];
  bool _ownedStoresLoaded = false;

  String? _lastStoreId;
  bool _profileLoaded = false;

  /// Legacy data migration: done (or nothing to migrate) / in progress.
  bool _migrated = false;
  bool _migrationStarted = false;
  bool _migrating = false;

  String? _selectedStoreId;
  bool _forcePicker = false;

  String? _errorMessage;
  bool _disposed = false;

  // ───────────────────────── Getters ─────────────────────────

  String? get errorMessage => _errorMessage;

  /// Non-archived stores owned by the user.
  List<Store> get ownedStores =>
      _ownedStores.where((s) => !s.archived).toList(growable: false);

  /// Employee link, if the user is an employee.
  Employee? get employee => _employee;

  /// An employee linked to a store cannot create stores (enforced by rules).
  bool get canCreateStore => _employeeLoaded && _employee == null;

  /// True when the user is linked to a store that is no longer available
  /// (archived or deleted): they can only leave it.
  bool get hasUnavailableStore =>
      _employee != null && _employeeStoreLoaded && !_isUsable(_employeeStore);

  SessionStatus get status {
    if (_errorMessage != null) return SessionStatus.error;
    if (!_employeeLoaded) return SessionStatus.loading;

    if (_employee != null) {
      if (!_employeeStoreLoaded) return SessionStatus.loading;
      return _isUsable(_employeeStore)
          ? SessionStatus.ready
          : SessionStatus.noStore;
    }

    if (!_ownedStoresLoaded || !_profileLoaded) return SessionStatus.loading;
    if (!_migrated) {
      return _migrating ? SessionStatus.migrating : SessionStatus.loading;
    }
    if (ownedStores.isEmpty) return SessionStatus.noStore;
    return _activeOwnedStore != null
        ? SessionStatus.ready
        : SessionStatus.pickStore;
  }

  /// The store currently active, if any.
  Store? get currentStore {
    if (status != SessionStatus.ready) return null;
    return _employee != null ? _employeeStore : _activeOwnedStore;
  }

  /// The active session, available only when [status] is ready.
  AppSession? get session {
    final store = currentStore;
    if (store == null) return null;
    return AppSession(
      uid: uid,
      storeId: store.id,
      role: _employee != null ? StoreRole.employee : StoreRole.owner,
      userName: userName,
    );
  }

  bool _isUsable(Store? store) => store != null && !store.archived;

  Store? get _activeOwnedStore {
    final stores = ownedStores;
    final candidates = <String?>[
      _selectedStoreId,
      if (!_forcePicker) _lastStoreId,
      if (!_forcePicker && stores.length == 1) stores.first.id,
    ];
    for (final id in candidates) {
      if (id == null) continue;
      for (final store in stores) {
        if (store.id == id) return store;
      }
    }
    return null;
  }

  // ───────────────────────── Actions ─────────────────────────

  /// Activates one of the owned stores and remembers it for next time.
  void selectStore(String storeId) {
    _selectedStoreId = storeId;
    _forcePicker = false;
    _lastStoreId = storeId;
    _notify();
    _profiles.setLastStoreId(uid, storeId).catchError((Object e) {
      debugPrint('Could not save last store: $e');
    });
  }

  /// Goes back to the store picker (owners).
  void switchStore() {
    _selectedStoreId = null;
    _forcePicker = true;
    _notify();
  }

  /// Creates a store owned by the user and enters it.
  Future<Failure?> createStore({
    required String name,
    String description = '',
    double iva = 0,
    double exchangeRate = 0,
  }) async {
    final result = await _stores.createStore(Store(
      id: '',
      name: name.trim(),
      description: description.trim(),
      ownerId: uid,
      iva: iva,
      exchangeRate: exchangeRate,
    ));
    return result.fold(
      onSuccess: (store) {
        selectStore(store.id);
        return null;
      },
      onError: (failure) => failure,
    );
  }

  /// Updates the active store (owner): name, description, IVA, rate.
  Future<Failure?> updateStore(Store store) async {
    final result = await _stores.updateStore(store);
    return result.fold(onSuccess: (_) => null, onError: (f) => f);
  }

  /// Joins a store as employee with an invitation [rawCode] (as typed).
  ///
  /// On success the employee link appears through the real-time stream and
  /// the session switches to that store by itself.
  Future<Failure?> joinStore(String rawCode) async {
    final repository = _invitations;
    if (repository == null) {
      return const UnknownFailure(message: 'Invitaciones no disponibles');
    }
    if (_employee != null) return InvitationFailure.alreadyEmployee;

    final code = Invitation.normalize(rawCode);
    if (!Invitation.isWellFormed(code)) return InvitationFailure.invalid;

    final read = await repository.getInvitation(code);
    Failure? readFailure;
    final invitation = read.fold<Invitation?>(
      onSuccess: (data) => data,
      onError: (failure) {
        readFailure = failure;
        return null;
      },
    );
    if (readFailure != null) return readFailure;
    if (invitation == null) return InvitationFailure.invalid;
    if (invitation.isUsed) return InvitationFailure.used;
    if (invitation.isExpired(_clock())) return InvitationFailure.expired;
    if (invitation.createdBy == uid ||
        _ownedStores.any((s) => s.id == invitation.storeId)) {
      return InvitationFailure.ownStore;
    }

    final result = await repository.acceptInvitation(
      invitation,
      Employee(
        uid: uid,
        storeId: invitation.storeId,
        name: userName,
        email: userEmail,
        invitationCode: code,
        createdAt: _clock(),
      ),
    );
    return result.fold(onSuccess: (_) => null, onError: (f) => f);
  }

  /// Leaves the store the user works in (employee).
  Future<Failure?> leaveStore() async {
    final result = await _employees.removeEmployee(uid);
    return result.fold(onSuccess: (_) => null, onError: (f) => f);
  }

  /// Retries after an error (the migration is idempotent).
  void retry() {
    _cancelSubscriptions();
    _errorMessage = null;
    _employee = null; // so the employee store is watched again
    _employeeLoaded = false;
    _employeeStoreLoaded = false;
    _ownedStoresLoaded = false;
    _profileLoaded = false;
    _migrationStarted = false;
    _migrating = false;
    _notify();
    _start();
  }

  // ───────────────────────── Internals ─────────────────────────

  void _start() {
    _employeeSub = _employees.watchEmployee(uid).listen(
      (employee) {
        final previousStoreId = _employee?.storeId;
        _employee = employee;
        _employeeLoaded = true;
        if (employee?.storeId != previousStoreId) {
          _watchEmployeeStore(employee?.storeId);
        }
        _onStateChanged();
      },
      onError: _onError,
    );

    _ownedStoresSub = _stores.watchOwnedStores(uid).listen(
      (stores) {
        _ownedStores = stores;
        _ownedStoresLoaded = true;
        _onStateChanged();
      },
      onError: _onError,
    );

    _profiles.getProfile(uid).then((profile) {
      _lastStoreId = profile.lastStoreId;
      _migrated = profile.isMigrated || _migration == null;
      _profileLoaded = true;
      _onStateChanged();
    }).catchError((Object e) {
      _onError(e);
    });
  }

  void _onStateChanged() {
    _maybeMigrate();
    _notify();
  }

  /// Starts the legacy migration once everything needed is known and the
  /// user is an owner (employees work with their store's data only).
  void _maybeMigrate() {
    if (_migrated || _migrationStarted || _errorMessage != null) return;
    if (!_employeeLoaded || !_ownedStoresLoaded || !_profileLoaded) return;
    if (_employee != null) return;
    _migrationStarted = true;
    _runMigration();
  }

  Future<void> _runMigration() async {
    final migration = _migration!;
    try {
      if (!await migration.hasLegacyData(uid)) {
        await _profiles.markMigrated(uid);
        _migrated = true;
        _notify();
        return;
      }

      _migrating = true;
      _notify();

      // Target: the first store the user created (e.g. while testing phase
      // 1); otherwise a new store with a deterministic id (safe to retry).
      final existing = ownedStores;
      final String storeId;
      if (existing.isNotEmpty) {
        storeId = existing.first.id;
      } else {
        final settings =
            await _loadDeviceSettings?.call() ?? (iva: 0.0, exchangeRate: 0.0);
        final created = await _stores.createStore(
          Store(
            id: legacyStoreId,
            name: 'Mi tienda',
            ownerId: uid,
            iva: settings.iva,
            exchangeRate: settings.exchangeRate,
          ),
          id: legacyStoreId,
        );
        storeId = created.fold(
          onSuccess: (store) => store.id,
          onError: (failure) => throw StateError(failure.message),
        );
      }

      final report = await migration.migrate(
        uid: uid,
        storeId: storeId,
        userName: userName,
      );
      debugPrint('Legacy data migrated to $storeId: ${report.total} documents');

      await _profiles.markMigrated(uid, storeId: storeId);
      _migrated = true;
      _migrating = false;
      selectStore(storeId);
    } catch (e) {
      debugPrint('Legacy migration failed: $e');
      _migrating = false;
      _errorMessage = 'No se pudieron preparar los datos de tu tienda. '
          'Verifica tu conexión e inténtalo de nuevo (no se perdió nada).';
      _notify();
    }
  }

  void _watchEmployeeStore(String? storeId) {
    _employeeStoreSub?.cancel();
    _employeeStore = null;
    _employeeStoreLoaded = false;
    if (storeId == null) return;

    _employeeStoreSub = _stores.watchStore(storeId).listen(
      (store) {
        _employeeStore = store;
        _employeeStoreLoaded = true;
        _notify();
      },
      onError: (Object error) {
        // The link may have just been removed (access revoked): treat the
        // store as unavailable instead of a global error.
        debugPrint('Error listening employee store: $error');
        _employeeStore = null;
        _employeeStoreLoaded = true;
        _notify();
      },
    );
  }

  void _onError(Object error) {
    debugPrint('Session error: $error');
    _errorMessage = 'No se pudieron cargar los datos de tu tienda. '
        'Verifica tu conexión e inténtalo de nuevo.';
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _cancelSubscriptions() {
    _employeeSub?.cancel();
    _ownedStoresSub?.cancel();
    _employeeStoreSub?.cancel();
    _employeeSub = null;
    _ownedStoresSub = null;
    _employeeStoreSub = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelSubscriptions();
    super.dispose();
  }
}
