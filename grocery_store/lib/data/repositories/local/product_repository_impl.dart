import 'package:grocery_store/data/models/product_model.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/repositories/local/product_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class ProductRepositoryImpl implements ProductRepository {
  String dbPath = 'my_database.db';
  DatabaseFactory dbFactory = databaseFactoryIo;
  late final Database db;
  var store = intMapStoreFactory.store('products');

  ProductRepositoryImpl() {
    initDatabase();
  }

  Future<void> initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();

    await dir.create(recursive: true);

    String path = join(dir.path, dbPath);

    db = await dbFactory.openDatabase(path);
  }

  @override
  Future<void> addProduct(Product product) async {
    ProductModel productModel = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      stockQuantity: product.stockQuantity,
    );

    await store.record(product.id).add(db, (productModel.toJson()));
  }

  @override
  Future<void> deleteProduct(int id) async {
    await store.record(id).delete(db);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    final result = await store.find(db).then((records) {
      return records.map((record) {
        return ProductModel.fromJson(record.value);
      }).toList();
    });
    return result.map<Product>((e) => e.toEntity()).toList();
  }

  @override
  Future<Product?> getProductById(int id) {
    return store.record(id).get(db).then((record) {
      if (record == null) return null;
      return ProductModel.fromJson(record).toEntity();
    });
  }

  @override
  Future<void> updateProduct(Product product) {
    ProductModel productModel = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      stockQuantity: product.stockQuantity,
    );

    return store.record(product.id).put(db, (productModel.toJson()));
  }
}
