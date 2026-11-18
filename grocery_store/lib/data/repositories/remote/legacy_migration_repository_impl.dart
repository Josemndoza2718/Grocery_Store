import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/domain/repositories/local/client_repository.dart';
import 'package:grocery_store/domain/repositories/remote/legacy_migration_repository.dart';

class LegacyMigrationRepositoryImpl implements LegacyMigrationRepository {
  LegacyMigrationRepositoryImpl({required ClientRepository localClients})
      : _localClients = localClients;

  /// Clients stored only on this device (Sembast), before clients moved to
  /// Firestore.
  final ClientRepository _localClients;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Writes per batch (Firestore allows 500; keep a margin).
  static const int _batchSize = 400;

  static const _legacyCollections = [
    'products',
    'clients',
    'carts',
    'sales-history',
  ];

  Query<Map<String, dynamic>> _legacy(String collection, String uid) =>
      _db.collection(collection).where('userId', isEqualTo: uid);

  @override
  Future<bool> hasLegacyData(String uid) async {
    for (final collection in _legacyCollections) {
      final snapshot = await _legacy(collection, uid).limit(1).get();
      if (snapshot.docs.isNotEmpty) return true;
    }
    return (await _localClients.getAllClients()).isNotEmpty;
  }

  @override
  Future<MigrationReport> migrate({
    required String uid,
    required String storeId,
    required String userName,
  }) async {
    final store = _db.collection('stores').doc(storeId);

    final products = await _copy(
      source: _legacy('products', uid),
      target: store.collection('products'),
    );

    // Clients: Firestore ones first, then the ones only on this device.
    var clients = await _copy(
      source: _legacy('clients', uid),
      target: store.collection('clients'),
    );
    clients += await _copyLocalClients(uid, store.collection('clients'));

    final carts = await _copy(
      source: _legacy('carts', uid),
      target: store.collection('carts'),
      transform: (data) => {
        ...data,
        if ((data['createdBy'] as String?)?.isNotEmpty != true)
          'createdBy': uid,
      },
    );

    // The security rules require soldBy == the user creating the sale.
    final sales = await _copy(
      source: _legacy('sales-history', uid),
      target: store.collection('sales'),
      transform: (data) => {
        ...data,
        'soldBy': uid,
        if ((data['soldByName'] as String?)?.isNotEmpty != true)
          'soldByName': userName,
      },
    );

    return MigrationReport(
      products: products,
      clients: clients,
      carts: carts,
      sales: sales,
    );
  }

  /// Copies the documents of [source] into [target] keeping their ids.
  /// Documents already present in [target] are skipped (idempotent).
  /// Returns how many documents of [source] are now in [target].
  Future<int> _copy({
    required Query<Map<String, dynamic>> source,
    required CollectionReference<Map<String, dynamic>> target,
    Map<String, dynamic> Function(Map<String, dynamic> data)? transform,
  }) async {
    final sourceDocs = (await source.get()).docs;
    if (sourceDocs.isEmpty) return 0;

    final existing = await _ids(target);
    final pending = sourceDocs.where((d) => !existing.contains(d.id)).toList();

    for (var i = 0; i < pending.length; i += _batchSize) {
      final batch = _db.batch();
      for (final doc in pending.skip(i).take(_batchSize)) {
        final data = {...doc.data(), 'id': doc.id};
        batch.set(target.doc(doc.id), transform?.call(data) ?? data);
      }
      await batch.commit();
    }

    // Verify that every source document is now in the store.
    final after = await _ids(target);
    final missing = sourceDocs.where((d) => !after.contains(d.id)).length;
    if (missing > 0) {
      throw StateError(
          'Migración incompleta en ${target.path}: faltan $missing documentos');
    }
    return sourceDocs.length;
  }

  Future<int> _copyLocalClients(
    String uid,
    CollectionReference<Map<String, dynamic>> target,
  ) async {
    final local = await _localClients.getAllClients();
    if (local.isEmpty) return 0;

    final existing = await _ids(target);
    final batch = _db.batch();
    var pending = 0;
    for (final client in local) {
      if (existing.contains(client.id)) continue;
      batch.set(target.doc(client.id), client.copyWith(userId: uid).toJson());
      pending++;
    }
    if (pending > 0) await batch.commit();
    return local.length;
  }

  Future<Set<String>> _ids(CollectionReference<Map<String, dynamic>> c) async =>
      (await c.get()).docs.map((d) => d.id).toSet();
}
