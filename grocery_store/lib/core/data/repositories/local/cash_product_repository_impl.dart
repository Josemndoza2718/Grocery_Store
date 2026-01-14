import 'package:grocery_store/core/data/models/cart_model.dart';
import 'package:grocery_store/core/data/models/product_model.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/repositories/local/cash_product_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class CashProductRepositoryImpl implements CashProductRepository {
  String dbPath = 'my_database.db';
  DatabaseFactory dbFactory = databaseFactoryIo;
  var store = intMapStoreFactory.store('cash_products');

  Future<Database> initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();

    await dir.create(recursive: true);

    String path = join(dir.path, dbPath);

    return await dbFactory.openDatabase(path);
  }

  @override
  Future<void> addCashProduct(Cart check) async {
    final db = await initDatabase();

    CartModel carModel = CartModel(
      id: check.id,
      ownerId: check.ownerId,
      ownerCarName: check.ownerCarName,
      products: check.products,
      status: check.status,
    );

    await store.record(int.parse(check.id)).add(db, (carModel.toJson()));
  }

  @override
  Future<void> deleteCashProduct(int id) async {
    final db = await initDatabase();
    await store.record(id).delete(db);
  }

  @override
  Future<List<Product>> getAllCashProducts() async {
    final db = await initDatabase();
    final result = await store.find(db).then((records) {
      return records.map((record) {
        return ProductModel.fromJson(record.value);
      }).toList();
    });
    return result.map<Product>((e) => e.toEntity()).toList();
  }

  @override
  Future<Product?> getCashProductById(int id) async {
    final db = await initDatabase();
    return store.record(id).get(db).then((record) {
      if (record == null) return null;
      return ProductModel.fromJson(record).toEntity();
    });
  }

  @override
  Future<void> updateCashProduct(Product product) async {
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
