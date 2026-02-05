import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/errors/firebase_error_handler.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/repositories/local/new/sales_history_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class SalesHistoryRepositoryImpl implements SalesHistoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sembast configuration (local persistence)
  final String _dbName = 'sales_history.db';
  final StoreRef<String, Map<String, dynamic>> _store =
      stringMapStoreFactory.store('sales');

  Future<Database> _getSembastDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, _dbName);
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  @override
  Future<Result<void>> createSale(Cart cart) async {
    final saleMap = cart.toJson();

    // 1. Save to Sembast (Local) - Immediate
    final sembastDb = await _getSembastDb();
    await _store.record(cart.id).put(sembastDb, saleMap);

    // 2. Save to Firestore (Cloud)
    return FirebaseErrorHandler.guard(() async {
      await _db.collection('sales-history').doc(cart.id).set(saleMap);
    });
  }

  @override
  Stream<List<Cart>> getSalesStream({String? userId}) {
    var query = _db.collection('sales-history');

    return (userId != null && userId.isNotEmpty
            ? query.where('userId', isEqualTo: userId)
            : query)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final sales = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Cart.fromJson(data);
      }).toList();

      // Sync to local storage in background
      _syncSalesToLocal(sales);

      return sales;
    });
  }

  Future<void> _syncSalesToLocal(List<Cart> sales) async {
    final sembastDb = await _getSembastDb();
    await _store.drop(sembastDb);

    for (final sale in sales) {
      await _store.record(sale.id).put(sembastDb, sale.toJson());
    }
  }

  @override
  Future<Result<List<Cart>>> getLocalSales() async {
    return FirebaseErrorHandler.guard(() async {
      final sembastDb = await _getSembastDb();
      final records = await _store.find(sembastDb);

      return records.map((r) => Cart.fromJson(r.value)).toList();
    });
  }
}
