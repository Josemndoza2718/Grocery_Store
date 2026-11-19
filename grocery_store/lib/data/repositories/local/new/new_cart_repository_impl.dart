import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/errors/firebase_error_handler.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/repositories/local/new/new_cart_repository.dart';

class NewCartRepositoryImpl implements NewCartRepository {
  NewCartRepositoryImpl({required this.storeId});

  final String storeId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _carts =>
      _db.collection('stores').doc(storeId).collection('carts');

  @override
  Stream<List<Cart>> getAllCartsStream() {
    return _carts.snapshots().map((snapshot) {
      final carts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Cart.fromJson(data);
      }).toList();
      carts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return carts;
    });
  }

  @override
  Future<Result<void>> createCart(Cart cart) {
    return FirebaseErrorHandler.guard(() async {
      await _carts.doc(cart.id).set(cart.toJson());
    });
  }

  @override
  Future<Result<void>> deleteCart(String id) {
    return FirebaseErrorHandler.guard(() async {
      await _carts.doc(id).delete();
    });
  }

  @override
  Future<Result<void>> updateCart(Cart cart) {
    return FirebaseErrorHandler.guard(() async {
      await _carts.doc(cart.id).set(cart.toJson(), SetOptions(merge: true));
    });
  }
}
