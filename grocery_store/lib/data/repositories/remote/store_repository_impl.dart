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
  Future<Result<Store>> createStore(Store store, {String? id}) {
    return FirebaseErrorHandler.guard(() async {
      final ref = id == null ? _stores.doc() : _stores.doc(id);
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
  Future<Result<void>> archiveStore(String storeId) {
    return FirebaseErrorHandler.guard(() async {
      await _stores.doc(storeId).update({
        'archived': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }
}
