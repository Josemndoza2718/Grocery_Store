import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_store/core/errors/failure.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/app_session.dart';
import 'package:grocery_store/domain/entities/employee.dart';
import 'package:grocery_store/domain/entities/store.dart';
import 'package:grocery_store/domain/repositories/remote/employee_repository.dart';
import 'package:grocery_store/domain/repositories/remote/store_repository.dart';
import 'package:grocery_store/domain/repositories/remote/user_profile_repository.dart';
import 'package:grocery_store/ui/view_model/session/session_controller.dart';

const _uid = 'owner-1';

Store _store(String id, {bool archived = false, int day = 1}) => Store(
      id: id,
      name: 'Tienda $id',
      ownerId: _uid,
      archived: archived,
      createdAt: DateTime(2026, 1, day),
    );

class FakeStoreRepository implements StoreRepository {
  final owned = StreamController<List<Store>>.broadcast();
  final watched = <String, StreamController<Store?>>{};
  Failure? createFailure;
  int _nextId = 100;

  StreamController<Store?> storeController(String id) =>
      watched.putIfAbsent(id, () => StreamController<Store?>.broadcast());

  @override
  Stream<List<Store>> watchOwnedStores(String ownerId) => owned.stream;

  @override
  Stream<Store?> watchStore(String storeId) => storeController(storeId).stream;

  @override
  Future<Result<Store>> createStore(Store store) async {
    if (createFailure != null) return Error(createFailure!);
    return Success(store.copyWith(id: 'new-${_nextId++}'));
  }

  @override
  Future<Result<void>> updateStore(Store store) async => const Success(null);

  @override
  Future<Result<void>> archiveStore(String storeId) async =>
      const Success(null);
}

class FakeEmployeeRepository implements EmployeeRepository {
  final employee = StreamController<Employee?>.broadcast();
  final removed = <String>[];

  @override
  Stream<Employee?> watchEmployee(String uid) => employee.stream;

  @override
  Stream<List<Employee>> watchStoreEmployees(String storeId) =>
      const Stream.empty();

  @override
  Future<Result<void>> removeEmployee(String uid) async {
    removed.add(uid);
    return const Success(null);
  }
}

class FakeUserProfileRepository implements UserProfileRepository {
  FakeUserProfileRepository([this.lastStoreId]);

  String? lastStoreId;
  final saved = <String>[];

  @override
  Future<String?> getLastStoreId(String uid) async => lastStoreId;

  @override
  Future<void> setLastStoreId(String uid, String storeId) async {
    saved.add(storeId);
  }
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeStoreRepository stores;
  late FakeEmployeeRepository employees;
  late FakeUserProfileRepository profiles;
  late SessionController controller;

  SessionController build({String? lastStoreId}) {
    profiles = FakeUserProfileRepository(lastStoreId);
    return SessionController(
      uid: _uid,
      storeRepository: stores,
      employeeRepository: employees,
      userProfileRepository: profiles,
    );
  }

  setUp(() {
    stores = FakeStoreRepository();
    employees = FakeEmployeeRepository();
  });

  tearDown(() => controller.dispose());

  test('is loading until employee link and owned stores are known', () async {
    controller = build();
    expect(controller.status, SessionStatus.loading);

    employees.employee.add(null);
    await _flush();
    expect(controller.status, SessionStatus.loading);

    stores.owned.add([]);
    await _flush();
    expect(controller.status, SessionStatus.noStore);
    expect(controller.canCreateStore, isTrue);
  });

  test('owner with a single store enters it automatically', () async {
    controller = build();
    employees.employee.add(null);
    stores.owned.add([_store('a')]);
    await _flush();

    expect(controller.status, SessionStatus.ready);
    expect(controller.session!.storeId, 'a');
    expect(controller.session!.role, StoreRole.owner);
    expect(controller.session!.isOwner, isTrue);
  });

  test('owner with several stores must pick one, unless a last store is saved',
      () async {
    controller = build();
    employees.employee.add(null);
    stores.owned.add([_store('a'), _store('b', day: 2)]);
    await _flush();
    expect(controller.status, SessionStatus.pickStore);

    controller.selectStore('b');
    expect(controller.status, SessionStatus.ready);
    expect(controller.session!.storeId, 'b');
    expect(profiles.saved, ['b']);
  });

  test('last used store is restored on start', () async {
    controller = build(lastStoreId: 'b');
    employees.employee.add(null);
    stores.owned.add([_store('a'), _store('b', day: 2)]);
    await _flush();

    expect(controller.status, SessionStatus.ready);
    expect(controller.session!.storeId, 'b');
  });

  test('archived stores are ignored', () async {
    controller = build(lastStoreId: 'a');
    employees.employee.add(null);
    stores.owned.add([_store('a', archived: true), _store('b', day: 2)]);
    await _flush();

    expect(controller.ownedStores.map((s) => s.id), ['b']);
    expect(controller.session!.storeId, 'b');
  });

  test('switchStore goes back to the picker even with a single store',
      () async {
    controller = build();
    employees.employee.add(null);
    stores.owned.add([_store('a')]);
    await _flush();
    expect(controller.status, SessionStatus.ready);

    controller.switchStore();
    expect(controller.status, SessionStatus.pickStore);

    controller.selectStore('a');
    expect(controller.status, SessionStatus.ready);
  });

  test('createStore enters the new store when it appears', () async {
    controller = build();
    employees.employee.add(null);
    stores.owned.add([]);
    await _flush();

    final failure = await controller.createStore(name: '  Mi tienda ');
    expect(failure, isNull);

    stores.owned.add([_store('new-100')]);
    await _flush();
    expect(controller.status, SessionStatus.ready);
    expect(controller.session!.storeId, 'new-100');
  });

  test('createStore returns the failure', () async {
    controller = build();
    stores.createFailure = const FirestoreFailure(message: 'sin permiso');
    final failure = await controller.createStore(name: 'X');
    expect(failure?.message, 'sin permiso');
  });

  test('employee enters their store with the employee role and cannot create stores',
      () async {
    controller = build();
    employees.employee.add(Employee(uid: _uid, storeId: 's1'));
    stores.owned.add([_store('own')]);
    await _flush();
    expect(controller.status, SessionStatus.loading); // waiting store doc

    stores.storeController('s1').add(_store('s1'));
    await _flush();

    expect(controller.status, SessionStatus.ready);
    expect(controller.session!.storeId, 's1');
    expect(controller.session!.role, StoreRole.employee);
    expect(controller.session!.canManageProducts, isFalse);
    expect(controller.canCreateStore, isFalse);
  });

  test('employee whose store was archived can only leave it', () async {
    controller = build();
    employees.employee.add(Employee(uid: _uid, storeId: 's1'));
    stores.owned.add([]);
    await _flush();
    stores.storeController('s1').add(_store('s1', archived: true));
    await _flush();

    expect(controller.status, SessionStatus.noStore);
    expect(controller.hasUnavailableStore, isTrue);

    await controller.leaveStore();
    expect(employees.removed, [_uid]);
  });

  test('being unlinked closes the employee session immediately', () async {
    controller = build();
    employees.employee.add(Employee(uid: _uid, storeId: 's1'));
    stores.owned.add([]);
    await _flush();
    stores.storeController('s1').add(_store('s1'));
    await _flush();
    expect(controller.status, SessionStatus.ready);

    employees.employee.add(null);
    await _flush();
    expect(controller.status, SessionStatus.noStore);
    expect(controller.session, isNull);
    expect(controller.canCreateStore, isTrue);
  });

  test('stream errors move to the error state and retry recovers', () async {
    controller = build();
    employees.employee.addError(Exception('permission-denied'));
    await _flush();
    expect(controller.status, SessionStatus.error);
    expect(controller.errorMessage, isNotNull);

    controller.retry();
    expect(controller.status, SessionStatus.loading);
    employees.employee.add(null);
    stores.owned.add([_store('a')]);
    await _flush();
    expect(controller.status, SessionStatus.ready);
  });
}
