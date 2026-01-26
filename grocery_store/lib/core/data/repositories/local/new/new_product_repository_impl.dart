import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/repositories/local/new/new_product_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class NewProductRepositoryImpl implements NewProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Configuración de Sembast (para persistencia local)
  final String _dbName = 'admin_products.db';
  final StoreRef<String, Map<String, dynamic>> _store =
      stringMapStoreFactory.store('products');

  Future<Database> _getSembastDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, _dbName);
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  @override
  Stream<List<Product>> getAllProductsStream({String? userId}) {
    // 1. Escuchar la colección 'products' en tiempo real, filtered by userId
    var query = _db.collection('products');
    
    return (userId != null && userId.isNotEmpty 
        ? query.where('userId', isEqualTo: userId)
        : query)
        .snapshots()
        .map((snapshot) {
      // 2. Mapear los documentos a una lista de objetos Product
      final products = snapshot.docs.map((doc) {
        // Asegurar que el ID del documento de Firestore se incluya en el modelo
        final data = doc.data();
        data['id'] = doc.id; // Asignar el UID de Firestore al campo 'id'
        return Product.fromJson(data);
      }).toList();

      // 3. Opcional: Sincronizar con Sembast en segundo plano (para mantener el caché local actualizado)
      _syncProductsToLocal(products);

      return products;
    });
  }

  // Método auxiliar para guardar los productos en Sembast
  Future<void> _syncProductsToLocal(List<Product> products) async {
    final sembastDb = await _getSembastDb();

    // Limpiar el almacén local antes de escribir los nuevos datos (una estrategia)
    await _store.drop(sembastDb);

    for (final product in products) {
      await _store.record(product.id).put(sembastDb, product.toJson());
    }

    print('Sincronización local de ${products.length} productos completada.');
  }

  // --- LÓGICA PRINCIPAL: CREAR Y PERSISTIR ---
  @override
  Future<void> createProduct(Product product) async {
    // 1. Crear un ID único de Firestore (UID)
    final newProductId = _db.collection('products').doc().id;
    final newProduct = product.copyWith(id: newProductId);
    final productMap = newProduct.toJson();

    // 2. Guardar en Firestore (Nube)
    await _db.collection('products').doc(newProductId).set(productMap);

    // 3. Guardar en Sembast (Local)
    final sembastDb = await _getSembastDb();
    await _store.record(newProductId).put(sembastDb, productMap);
  }

  @override
  Future<void> deleteProduct(String id) async {
    // 1. Eliminar de Firestore
    await _db.collection('products').doc(id).delete();

    // 2. Eliminar de Sembast
    final sembastDb = await _getSembastDb();
    await _store.record(id).delete(sembastDb);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final productMap = product.toJson();

    // 1. Actualizar en Firestore
    await _db.collection('products').doc(product.id).update(productMap);

    // 2. Actualizar en Sembast
    final sembastDb = await _getSembastDb();
    await _store.record(product.id).put(sembastDb, productMap);
  }

  // --- LECTURA SIN CONEXIÓN (Sembast) ---
  @override
  Future<List<Product>> getLocalProducts() async {
    final sembastDb = await _getSembastDb();
    final records = await _store.find(sembastDb);

    return records.map((r) => Product.fromJson(r.value)).toList();
  }
}
