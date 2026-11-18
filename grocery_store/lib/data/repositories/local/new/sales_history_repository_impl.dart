import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/repositories/local/new/sales_history_repository.dart';

class SalesHistoryRepositoryImpl implements SalesHistoryRepository {
  SalesHistoryRepositoryImpl({required this.storeId});

  final String storeId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<List<Cart>> getSalesStream({String? soldBy}) {
    Query<Map<String, dynamic>> query =
        _db.collection('stores').doc(storeId).collection('sales');
    if (soldBy != null) {
      // Uses the composite index (soldBy ASC, updatedAt DESC).
      query = query.where('soldBy', isEqualTo: soldBy);
    }
    return query
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Cart.fromJson(data);
            }).toList());
  }
}
