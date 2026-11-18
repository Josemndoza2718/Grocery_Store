import 'package:grocery_store/domain/entities/client.dart';

abstract class ClientRepository {
  Future<void> addClient(Client client);
  Future<void> updateClient(Client client);
  Future<void> deleteClient(String id);
  Future<Client?> getClientById(String id);
  Future<List<Client>> getAllClients();
}
