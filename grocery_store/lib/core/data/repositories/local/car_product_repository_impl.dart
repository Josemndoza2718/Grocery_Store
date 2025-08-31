import 'package:grocery_store/core/data/models/cart_model.dart';
import 'package:grocery_store/core/data/models/product_model.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/repositories/local/car_product_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class CartRepositoryImpl implements CarProductRepository {
  String dbPath = 'my_database.db';
  DatabaseFactory dbFactory = databaseFactoryIo;
  var store = intMapStoreFactory.store('car_products');

  Future<Database> initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();

    await dir.create(recursive: true);

    String path = join(dir.path, dbPath);

    return await dbFactory.openDatabase(path);
  }

  @override
  Future<void> addCarProduct(Cart cart) async {
    final db = await initDatabase();

    CartModel cartModel = CartModel(
        id: cart.id,
        ownerId: cart.ownerId,
        ownerCarName: cart.ownerCarName,
        status: cart.status,
        products: cart.products);

    await store.record(cart.id).add(db, (cartModel.toJson()));
    //await store.addAll(db, cart.products.map((e) => cartModel.toJson()).toList());
  }

  @override
  Future<void> deleteCarProduct(int id) async {
    final db = await initDatabase();
    //final finder = Finder(filter: Filter.byKey(id));

    //await store.delete(db, finder: finder);
    //await store.delete(db);
    await store.record(id).delete(db);
  }

  @override
  Future<List<Cart>> getAllCarProducts() async {
    final db = await initDatabase();
    final result = await store.find(db).then((records) {
      return records.map((record) {
        return CartModel.fromJson(record.value);
      }).toList();
    });
    return result.map<Cart>((e) => e.toEntity()).toList();
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
  Future<void> updateCarProduct(Cart cart) async {
    final db = await initDatabase();

    CartModel cartModel = CartModel(
        id: cart.id,
        ownerId: cart.ownerId,
        ownerCarName: cart.ownerCarName,
        status: cart.status,
        products: cart.products);

    store.record(cart.id).put(db, (cartModel.toJson()));
  }
}
