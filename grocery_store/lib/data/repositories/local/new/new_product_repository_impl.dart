import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/errors/firebase_error_handler.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/repositories/local/new/new_product_repository.dart';

class NewProductRepositoryImpl implements NewProductRepository {
  NewProductRepositoryImpl({required this.storeId});

  final String storeId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('stores').doc(storeId).collection('products');

  List<Product> _map(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final products = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Product.fromJson(data);
    }).toList();
    // Newest first, sorted in memory (documents without createdAt included).
    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

  @override
  Stream<List<Product>> getAllProductsStream() =>
      _products.snapshots().map(_map);

  @override
  Future<Result<List<Product>>> getProducts() {
    return FirebaseErrorHandler.guard(() async => _map(await _products.get()));
  }

  @override
  Future<Result<void>> createProduct(Product product) {
    return FirebaseErrorHandler.guard(() async {
      final ref = _products.doc();
      await ref.set(product.copyWith(id: ref.id).toJson());
    });
  }

  @override
  Future<Result<void>> deleteProduct(String id) {
    return FirebaseErrorHandler.guard(() async {
      await _products.doc(id).delete();
    });
  }

  @override
  Future<Result<void>> updateProduct(Product product) {
    return FirebaseErrorHandler.guard(() async {
      await _products.doc(product.id).update(product.toJson());
    });
  }
}
