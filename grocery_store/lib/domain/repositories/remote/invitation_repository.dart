import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/employee.dart';
import 'package:grocery_store/domain/entities/invitation.dart';

abstract class InvitationRepository {
  /// Creates a new single-use invitation for [storeId] (owner) with a unique
  /// random code, valid for [Invitation.validity].
  Future<Result<Invitation>> createInvitation({
    required String storeId,
    required String storeName,
    required String createdBy,
  });

  /// Reads an invitation by its (normalized) code; `null` if it does not exist.
  Future<Result<Invitation?>> getInvitation(String code);

  /// Real-time invitations created by [createdBy] for [storeId] (owner).
  Stream<List<Invitation>> watchStoreInvitations({
    required String storeId,
    required String createdBy,
  });

  /// Atomically creates the employee link and marks the invitation as used
  /// by [employee.uid]. The security rules validate the invitation.
  Future<Result<void>> acceptInvitation(
      Invitation invitation, Employee employee);

  /// Deletes a pending invitation (owner).
  Future<Result<void>> revokeInvitation(String code);
}
