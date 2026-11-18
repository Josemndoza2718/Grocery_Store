import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/errors/firebase_error_handler.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/employee.dart';
import 'package:grocery_store/domain/repositories/remote/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _employees =>
      _db.collection('employees');

  @override
  Stream<Employee?> watchEmployee(String uid) {
    return _employees.doc(uid).snapshots().map(
          (doc) => doc.exists ? Employee.fromJson(doc.id, doc.data()!) : null,
        );
  }

  @override
  Stream<List<Employee>> watchStoreEmployees(String storeId) {
    return _employees.where('storeId', isEqualTo: storeId).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Employee.fromJson(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<Result<void>> removeEmployee(String uid) {
    return FirebaseErrorHandler.guard(() async {
      await _employees.doc(uid).delete();
    });
  }
}
