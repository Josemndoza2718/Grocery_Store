import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grocery_store/core/errors/failure.dart';
import 'package:grocery_store/domain/entities/employee.dart';
import 'package:grocery_store/domain/entities/invitation.dart';
import 'package:grocery_store/domain/repositories/remote/employee_repository.dart';
import 'package:grocery_store/domain/repositories/remote/invitation_repository.dart';

/// Employees and pending invitations of the active store (owner only).
class EmployeesViewModel extends ChangeNotifier {
  EmployeesViewModel({
    required this.storeId,
    required this.ownerId,
    required EmployeeRepository employeeRepository,
    required InvitationRepository invitationRepository,
    DateTime Function()? clock,
  })  : _employeesRepo = employeeRepository,
        _invitationsRepo = invitationRepository,
        _clock = clock ?? DateTime.now;

  final String storeId;
  final String ownerId;
  final EmployeeRepository _employeesRepo;
  final InvitationRepository _invitationsRepo;
  final DateTime Function() _clock;

  StreamSubscription<List<Employee>>? _employeesSub;
  StreamSubscription<List<Invitation>>? _invitationsSub;

  List<Employee> _employees = [];
  List<Invitation> _invitations = [];
  bool _employeesLoaded = false;
  bool _invitationsLoaded = false;
  bool _creating = false;
  String? _errorMessage;
  bool _disposed = false;

  List<Employee> get employees => _employees;

  /// Invitations that can still be used (not used, not expired).
  List<Invitation> get pendingInvitations =>
      _invitations.where((i) => i.isPending(_clock())).toList();

  bool get isLoading => !_employeesLoaded || !_invitationsLoaded;
  bool get isCreatingInvitation => _creating;
  String? get errorMessage => _errorMessage;

  /// Starts listening (called when the employees screen opens).
  void start() {
    if (_employeesSub != null) return;
    _employeesSub = _employeesRepo.watchStoreEmployees(storeId).listen(
      (list) {
        _employees = list
          ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _employeesLoaded = true;
        _notify();
      },
      onError: _onError,
    );
    _invitationsSub = _invitationsRepo
        .watchStoreInvitations(storeId: storeId, createdBy: ownerId)
        .listen(
      (list) {
        _invitations = list;
        _invitationsLoaded = true;
        _notify();
      },
      onError: _onError,
    );
  }

  /// Creates a new invitation code to share.
  Future<({Invitation? invitation, Failure? failure})> createInvitation(
      String storeName) async {
    if (_creating) return (invitation: null, failure: null);
    _creating = true;
    _notify();
    final result = await _invitationsRepo.createInvitation(
      storeId: storeId,
      storeName: storeName,
      createdBy: ownerId,
    );
    _creating = false;
    _notify();
    return result.fold(
      onSuccess: (inv) => (invitation: inv, failure: null),
      onError: (f) => (invitation: null, failure: f),
    );
  }

  Future<Failure?> revokeInvitation(String code) async {
    final result = await _invitationsRepo.revokeInvitation(code);
    return result.fold(onSuccess: (_) => null, onError: (f) => f);
  }

  /// Unlinks an employee: they lose access to the store immediately.
  Future<Failure?> removeEmployee(String uid) async {
    final result = await _employeesRepo.removeEmployee(uid);
    return result.fold(onSuccess: (_) => null, onError: (f) => f);
  }

  void _onError(Object error) {
    debugPrint('Employees error: $error');
    _errorMessage = 'No se pudo cargar la lista de empleados.';
    _employeesLoaded = true;
    _invitationsLoaded = true;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _employeesSub?.cancel();
    _invitationsSub?.cancel();
    super.dispose();
  }
}
