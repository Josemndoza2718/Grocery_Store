import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/employee.dart';

abstract class EmployeeRepository {
  /// Real-time employee link of [uid]; emits `null` if the user is not an
  /// employee of any store.
  Stream<Employee?> watchEmployee(String uid);

  /// Real-time list of the employees of [storeId] (owner only).
  Stream<List<Employee>> watchStoreEmployees(String storeId);

  /// Unlinks the employee [uid] from their store (owner) or leaves it (self).
  Future<Result<void>> removeEmployee(String uid);
}
