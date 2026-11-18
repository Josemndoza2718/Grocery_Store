import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/errors/firebase_error_handler.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/employee.dart';
import 'package:grocery_store/domain/entities/invitation.dart';
import 'package:grocery_store/domain/repositories/remote/invitation_repository.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _db.collection('invitations');

  /// Dates are stored as Firestore Timestamps: the security rules compare
  /// `expiresAt` with `request.time`.
  Invitation _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    DateTime? date(Object? value) => value is Timestamp ? value.toDate() : null;
    return Invitation(
      code: doc.id,
      storeId: data['storeId'] as String? ?? '',
      storeName: data['storeName'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: date(data['createdAt']) ?? DateTime.now(),
      expiresAt: date(data['expiresAt']) ?? DateTime.now(),
      usedBy: data['usedBy'] as String?,
      usedAt: date(data['usedAt']),
    );
  }

  @override
  Future<Result<Invitation>> createInvitation({
    required String storeId,
    required String storeName,
    required String createdBy,
  }) {
    return FirebaseErrorHandler.guard(() async {
      final now = DateTime.now();
      final expiresAt = now.add(Invitation.validity);

      // Very unlikely, but make sure the random code is not taken.
      for (var attempt = 0; attempt < 5; attempt++) {
        final code = Invitation.generateCode();
        final ref = _invitations.doc(code);
        final created = await _db.runTransaction<bool>((tx) async {
          if ((await tx.get(ref)).exists) return false;
          tx.set(ref, {
            'storeId': storeId,
            'storeName': storeName,
            'createdBy': createdBy,
            'createdAt': Timestamp.fromDate(now),
            'expiresAt': Timestamp.fromDate(expiresAt),
            'usedBy': null,
            'usedAt': null,
          });
          return true;
        });
        if (created) {
          return Invitation(
            code: code,
            storeId: storeId,
            storeName: storeName,
            createdBy: createdBy,
            createdAt: now,
            expiresAt: expiresAt,
          );
        }
      }
      throw StateError('No se pudo generar un código único');
    });
  }

  @override
  Future<Result<Invitation?>> getInvitation(String code) {
    return FirebaseErrorHandler.guard(() async {
      final doc = await _invitations.doc(code).get();
      return doc.exists ? _fromDoc(doc) : null;
    });
  }

  @override
  Stream<List<Invitation>> watchStoreInvitations({
    required String storeId,
    required String createdBy,
  }) {
    return _invitations
        .where('createdBy', isEqualTo: createdBy)
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(_fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<Result<void>> acceptInvitation(
    Invitation invitation,
    Employee employee,
  ) {
    return FirebaseErrorHandler.guard(() async {
      final batch = _db.batch();
      batch.set(
          _db.collection('employees').doc(employee.uid), employee.toJson());
      batch.update(_invitations.doc(invitation.code), {
        'usedBy': employee.uid,
        'usedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    });
  }

  @override
  Future<Result<void>> revokeInvitation(String code) {
    return FirebaseErrorHandler.guard(() async {
      await _invitations.doc(code).delete();
    });
  }
}
