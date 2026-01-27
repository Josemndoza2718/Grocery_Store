import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/errors/firebase_error_handler.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/repositories/local/new/new_cart_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class NewCartRepositoryImpl implements NewCartRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Configuración de Sembast (para persistencia local)
  final String _dbName = 'carts.db';
  final StoreRef<String, Map<String, dynamic>> _store =
      stringMapStoreFactory.store('carts');

  Future<Database> _getSembastDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, _dbName);
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  @override
  Stream<List<Cart>> getAllCartsStream({String? userId}) {
    // 1. Escuchar la colección 'carts' en tiempo real, filtered by userId
    var query = _db.collection('carts');
    
    return (userId != null && userId.isNotEmpty 
        ? query.where('userId', isEqualTo: userId)
        : query)
        .snapshots()
        .map((snapshot) {
       // 2. Mapear los documentos a una lista de objetos Cart
      final carts = snapshot.docs.map((doc) {
        final data = doc.data();
        // Usar el ID del documento directamente (ya es String)
        data['id'] = doc.id;
        return Cart.fromJson(data);
      }).toList();

      // 3. Sincronizar con Sembast en segundo plano
      _syncCartsToLocal(carts);

      return carts;
    });
  }

  // Método auxiliar para guardar los carritos en Sembast
  Future<void> _syncCartsToLocal(List<Cart> carts) async {
    final sembastDb = await _getSembastDb();

    // Limpiar el almacén local antes de escribir los nuevos datos
    await _store.drop(sembastDb);

    for (final cart in carts) {
      await _store.record(cart.id).put(sembastDb, cart.toJson());
    }

    print('Sincronización local de ${carts.length} carritos completada.');
  }

  @override
  Future<Result<void>> createCart(Cart cart) async {
    return FirebaseErrorHandler.guard(() async {
      final cartMap = cart.toJson();

      // 1. Guardar en Firestore (Nube) usando el ID como documento
      await _db.collection('carts').doc(cart.id).set(cartMap);

      // 2. Guardar en Sembast (Local)
      final sembastDb = await _getSembastDb();
      await _store.record(cart.id).put(sembastDb, cartMap);
    });
  }

  @override
  Future<Result<void>> deleteCart(String id) async {
    return FirebaseErrorHandler.guard(() async {
      // 1. Eliminar de Firestore
      await _db.collection('carts').doc(id).delete();

      // 2. Eliminar de Sembast
      final sembastDb = await _getSembastDb();
      await _store.record(id).delete(sembastDb);
    });
  }

  @override
  Future<Result<void>> updateCart(Cart cart) async {
    return FirebaseErrorHandler.guard(() async {
      final cartMap = cart.toJson();

      // 1. Actualizar en Firestore (usar set con merge para evitar NOT_FOUND)
      await _db.collection('carts').doc(cart.id).set(
            cartMap,
            SetOptions(merge: true),
          );

      // 2. Actualizar en Sembast
      final sembastDb = await _getSembastDb();
      await _store.record(cart.id).put(sembastDb, cartMap);
    });
  }

  @override
  Future<Result<List<Cart>>> getLocalCarts() async {
    return FirebaseErrorHandler.guard(() async {
      final sembastDb = await _getSembastDb();
      final records = await _store.find(sembastDb);

      return records.map((r) => Cart.fromJson(r.value)).toList();
    });
  }
}
