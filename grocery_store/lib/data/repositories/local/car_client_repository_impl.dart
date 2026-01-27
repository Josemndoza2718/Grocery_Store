import 'package:grocery_store/data/models/client_model.dart';
import 'package:grocery_store/domain/entities/client.dart';
import 'package:grocery_store/domain/repositories/local/client_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class ClientRepositoryImpl implements ClientRepository {
  String dbPath = 'my_database.db';
  DatabaseFactory dbFactory = databaseFactoryIo;
  //late final Database db;
  var store = intMapStoreFactory.store('car_clients');

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
  Future<void> addClient(Client client) async {

    final db = await initDatabase(); 

    ClientModel clientModel = ClientModel(
      id: client.id,
      name: client.name,
    );

    await store.record(client.id).add(db, (clientModel.toJson()));
  }

  @override
  Future<void> deleteClient(int id) async {
    final db = await initDatabase();
    await store.record(id).delete(db);
  }

  @override
  Future<List<Client>> getAllClients() async {
    final db = await initDatabase();
    final result = await store.find(db).then((records) {
      return records.map((record) {
        return ClientModel.fromJson(record.value);
      }).toList();
    });
    return result.map<Client>((e) => e.toEntity()).toList();
  }

  @override
  Future<Client?> getClientById(int id) async {
    final db = await initDatabase();
    return store.record(id).get(db).then((record) {
      if (record == null) return null;
      return ClientModel.fromJson(record).toEntity();
    });
  }

  @override
  Future<void> updateClient(Client client) async {
    final db = await initDatabase();
    ClientModel clientModel = ClientModel(
      id: client.id,
      name: client.name,
    );

    store.record(client.id).put(db, (clientModel.toJson()));
  }
}
