import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/errors/firebase_error_handler.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/client.dart';
import 'package:grocery_store/domain/repositories/local/new/new_client_repository.dart';

/// Firestore implementation of [NewClientRepository].
///
/// Offline support relies on Firestore's built-in persistence (enabled by
/// default on Android/iOS): writes made offline are queued and synced later,
/// and the stream serves cached data while there is no connection.
class NewClientRepositoryImpl implements NewClientRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clients =>
      _db.collection('clients');

  @override
  Stream<List<Client>> getClientsStream({required String userId}) {
    return _clients
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final clients = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Client.fromJson(data);
      }).toList();

      // Sorted in memory to avoid requiring a composite index.
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
      await _clients.doc(client.id).set(
            client.toJson(),
            SetOptions(merge: true),
          );
    });
  }

  @override
  Future<Result<void>> deleteClient(String id) {
    return FirebaseErrorHandler.guard(() async {
      await _clients.doc(id).delete();
    });
  }
}
