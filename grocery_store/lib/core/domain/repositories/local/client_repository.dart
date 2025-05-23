import 'package:grocery_store/core/domain/entities/client.dart';

abstract class ClientRepository {
  Future<void> addClient(Client client);
  Future<void> updateClient(Client client);
  Future<void> deleteClient(int id);
  Future<Client?> getClientById(int id);
  Future<List<Client>> getAllClients();
}