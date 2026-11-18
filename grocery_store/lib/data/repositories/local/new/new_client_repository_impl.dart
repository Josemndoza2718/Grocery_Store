import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/errors/firebase_error_handler.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/client.dart';
import 'package:grocery_store/domain/repositories/local/new/new_client_repository.dart';

/// Firestore implementation of [NewClientRepository].
///
/// Offline support relies on Firestore's built-in persistence: writes made
/// offline are queued and synced later, and the stream serves cached data.
class NewClientRepositoryImpl implements NewClientRepository {
  NewClientRepositoryImpl({required this.storeId});

  final String storeId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clients =>
      _db.collection('stores').doc(storeId).collection('clients');

  @override
  Stream<List<Client>> getClientsStream() {
    return _clients.snapshots().map((snapshot) {
      final clients = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Client.fromJson(data);
      }).toList();
      clients
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return clients;
    });
  }

  @override
  Future<Result<void>> createClient(Client client) {
    return FirebaseErrorHandler.guard(() async {
      await _clients.doc(client.id).set(client.toJson());
    });
  }

  @override
  Future<Result<void>> updateClient(Client client) {
    return FirebaseErrorHandler.guard(() async {
      await _clients
          .doc(client.id)
          .set(client.toJson(), SetOptions(merge: true));
    });
  }

  @override
  Future<Result<void>> deleteClient(String id) {
    return FirebaseErrorHandler.guard(() async {
      await _clients.doc(id).delete();
    });
  }
}
