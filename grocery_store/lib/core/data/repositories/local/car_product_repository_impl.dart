import 'package:grocery_store/core/data/models/product_model.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/repositories/local/car_product_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class CarProductRepositoryImpl implements CarProductRepository {
  String dbPath = 'my_database.db';
  DatabaseFactory dbFactory = databaseFactoryIo;
  //late final Database db;
  var store = intMapStoreFactory.store('car_products');

  /* ProductRepositoryImpl() {
    initDatabase();
  } */

  Future<Database> initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();

    await dir.create(recursive: true);

    String path = join(dir.path, dbPath);

    return await dbFactory.openDatabase(path);
  }

  @override
  Future<void> addCarProduct(Product product) async {

    final db =await initDatabase(); 

    ProductModel productModel = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      image: product.image,
      categoryId: product.categoryId,
      category: product.category,
      idStock: product.idStock,
      stockQuantity: product.stockQuantity,
      quantity: product.quantity
    );

    await store.record(product.id).add(db, (productModel.toJson()));
  }

  @override
  Future<void> deleteCarProduct(int id) async {
    final db = await initDatabase();
    await store.record(id).delete(db);
  }

  @override
  Future<List<Product>> getAllCarProducts() async {
    final db = await initDatabase();
    final result = await store.find(db).then((records) {
      return records.map((record) {
        return ProductModel.fromJson(record.value);
      }).toList();
    });
    return result.map<Product>((e) => e.toEntity()).toList();
  }

  @override
  Future<Product?> getCarProductById(int id) async {
    final db = await initDatabase();
    return store.record(id).get(db).then((record) {
      if (record == null) return null;
      return ProductModel.fromJson(record).toEntity();
    });
  }

  @override
  Future<void> updateCarProduct(Product product) async {
    final db = await initDatabase();
    ProductModel productModel = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      image: product.image,
      categoryId: product.categoryId,
      category: product.category,
      idStock: product.idStock,
      stockQuantity: product.stockQuantity,
      quantity: product.quantity
    );

    store.record(product.id).put(db, (productModel.toJson()));
  }
}
