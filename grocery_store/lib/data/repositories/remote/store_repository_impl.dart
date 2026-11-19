import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/errors/firebase_error_handler.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/store.dart';
import 'package:grocery_store/domain/repositories/remote/store_repository.dart';

class StoreRepositoryImpl implements StoreRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _stores =>
      _db.collection('stores');

  Store _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    data['id'] = doc.id;
    return Store.fromJson(data);
  }

  @override
  Stream<List<Store>> watchOwnedStores(String ownerId) {
    return _stores
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final stores = snapshot.docs.map(_fromDoc).toList();
      // Sorted in memory (oldest first) to avoid a composite index.
      stores.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return stores;
    });
  }

  @override
  Stream<Store?> watchStore(String storeId) {
    return _stores
        .doc(storeId)
        .snapshots()
        .map((doc) => doc.exists ? _fromDoc(doc) : null);
  }

  @override
  Future<Result<Store>> createStore(Store store) {
    return FirebaseErrorHandler.guard(() async {
      final ref = _stores.doc();
      final now = DateTime.now();
      final created = store.copyWith(
        id: ref.id,
        archived: false,
        createdAt: now,
        updatedAt: now,
      );
      await ref.set(created.toJson());
      return created;
    });
  }

  @override
  Future<Result<void>> updateStore(Store store) {
    return FirebaseErrorHandler.guard(() async {
      await _stores.doc(store.id).update({
        'name': store.name,
        'description': store.description,
        'iva': store.iva,
        'exchangeRate': store.exchangeRate,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  @override
  Future<Result<void>> archiveStore(String storeId, {required String ownerId}) {
    return FirebaseErrorHandler.guard(() async {
      final employees = await _db
          .collection('employees')
          .where('storeId', isEqualTo: storeId)
          .get();
      final invitations = await _db
          .collection('invitations')
          .where('createdBy', isEqualTo: ownerId)
          .where('storeId', isEqualTo: storeId)
          .get();

      // One atomic batch: nobody keeps access to an archived store.
      final batch = _db.batch();
      for (final doc in employees.docs) {
        batch.delete(doc.reference);
      }
      for (final doc in invitations.docs) {
        // Used invitations are kept as history; pending ones are revoked.
        if (doc.data()['usedBy'] == null) batch.delete(doc.reference);
      }
      batch.update(_stores.doc(storeId), {
        'archived': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      await batch.commit();
    });
  }

  @override
  Future<Result<void>> restoreStore(String storeId) {
    return FirebaseErrorHandler.guard(() async {
      await _stores.doc(storeId).update({
        'archived': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }
}
