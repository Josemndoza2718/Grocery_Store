import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grocery_store/core/errors/failure.dart';
import 'package:grocery_store/domain/entities/app_session.dart';
import 'package:grocery_store/domain/entities/employee.dart';
import 'package:grocery_store/domain/entities/store.dart';
import 'package:grocery_store/domain/repositories/remote/employee_repository.dart';
import 'package:grocery_store/domain/repositories/remote/store_repository.dart';
import 'package:grocery_store/domain/repositories/remote/user_profile_repository.dart';

enum SessionStatus {
  /// Still resolving the user's stores / employee link.
  loading,

  /// The user has no store to work in (must create one or join with a code).
  noStore,

  /// The user owns several stores and must choose one.
  pickStore,

  /// A store is active: [SessionController.session] is available.
  ready,

  /// The store data could not be loaded (e.g. permissions, network).
  error,
}

/// Resolves, for the logged-in user [uid], which store they work in and with
/// which role. One instance per authenticated user (recreated on login).
///
/// Rules:
/// - If `employees/{uid}` exists → employee of that store (it has priority).
/// - Otherwise → owner: auto-enters the selected / last used store, or the
///   only one; with several stores and no valid choice → [SessionStatus.pickStore].
class SessionController extends ChangeNotifier {
  SessionController({
    required this.uid,
    required StoreRepository storeRepository,
    required EmployeeRepository employeeRepository,
    required UserProfileRepository userProfileRepository,
  })  : _stores = storeRepository,
        _employees = employeeRepository,
        _profiles = userProfileRepository {
    _start();
  }

  final String uid;
  final StoreRepository _stores;
  final EmployeeRepository _employees;
  final UserProfileRepository _profiles;

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
  bool _lastStoreLoaded = false;

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

    if (!_ownedStoresLoaded || !_lastStoreLoaded) return SessionStatus.loading;
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

  /// Updates name/description of the active store (owner).
  Future<Failure?> updateStore(Store store) async {
    final result = await _stores.updateStore(store);
    return result.fold(onSuccess: (_) => null, onError: (f) => f);
  }

  /// Leaves the store the user works in (employee).
  Future<Failure?> leaveStore() async {
    final result = await _employees.removeEmployee(uid);
    return result.fold(onSuccess: (_) => null, onError: (f) => f);
  }

  /// Retries after an error.
  void retry() {
    _cancelSubscriptions();
    _errorMessage = null;
    _employee = null; // so the employee store is watched again
    _employeeLoaded = false;
    _employeeStoreLoaded = false;
    _ownedStoresLoaded = false;
    _lastStoreLoaded = false;
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
        _notify();
      },
      onError: _onError,
    );

    _ownedStoresSub = _stores.watchOwnedStores(uid).listen(
      (stores) {
        _ownedStores = stores;
        _ownedStoresLoaded = true;
        _notify();
      },
      onError: _onError,
    );

    _profiles.getLastStoreId(uid).then((id) {
      _lastStoreId = id;
    }).catchError((Object e) {
      // Not critical: the user will just pick the store again.
      debugPrint('Could not read last store: $e');
    }).whenComplete(() {
      _lastStoreLoaded = true;
      _notify();
    });
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
