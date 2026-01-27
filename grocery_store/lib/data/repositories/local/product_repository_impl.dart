import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/data/models/product_model.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/repositories/local/product_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class ProductRepositoryImpl implements ProductRepository {
  String dbPath = 'my_database.db';
  DatabaseFactory dbFactory = databaseFactoryIo;
  var store = intMapStoreFactory.store('products');

  final productsFirebaseCollection =
      FirebaseFirestore.instance.collection('products');

  Future<Database> initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();

    await dir.create(recursive: true);

    String path = join(dir.path, dbPath);

    return await dbFactory.openDatabase(path);
  }

  @override
  Future<void> sendProductsToFirebase() async {
    try {
      final localProducts = await getAllProducts();

      if (localProducts.isEmpty) {
        print('No hay productos locales para sincronizar.');
        return;
      }

      for (var product in localProducts) {
        // Convierte el objeto Product a un Map
        final productData = {
          'id': product.id,
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'image': product.image,
          'idStock': product.idStock,
          'stockQuantity': product.stockQuantity,
          'quantity': product.quantityToBuy,
        };

        // Usa 'set' para asegurar que el ID del documento en Firestore sea el mismo que en Sembast.
        // Esto evita duplicados si se vuelve a sincronizar.
        await productsFirebaseCollection
            .doc(product.id.toString())
            .set(productData);
      }
      print('¡Sincronización de productos a Firebase completada con éxito!');
    } catch (e) {
      print('Error al sincronizar productos a Firebase: $e');
    }
  }

  @override
  Future<void> addProduct(Product product) async {
    final db = await initDatabase();

    ProductModel productModel = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        image: product.image,
        idStock: product.idStock,
        stockQuantity: product.stockQuantity,
        quantityToBuy: product.quantityToBuy);

    await store.record(int.parse(product.id)).add(db, (productModel.toJson()));
  }

  @override
  Future<void> deleteProduct(String id) async {
    final db = await initDatabase();
    await store.record(int.parse(id)).delete(db);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final db = await initDatabase();
    final result = await store.find(db).then((records) {
      return records.map((record) {
        return ProductModel.fromJson(record.value);
      }).toList();
    });
    return result.map<Product>((e) => e.toEntity()).toList();
  }

  @override
  Future<Product?> getProductById(int id) async {
    final db = await initDatabase();
    return store.record(id).get(db).then((record) {
      if (record == null) return null;
      return ProductModel.fromJson(record).toEntity();
    });
  }

  @override
  Future<void> updateProduct(Product product) async {
    final db = await initDatabase();
    ProductModel productModel = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        image: product.image,
        idStock: product.idStock,
        stockQuantity: product.stockQuantity,
        quantityToBuy: product.quantityToBuy);

    store.record(int.parse(product.id)).put(db, (productModel.toJson()));
  }
}
