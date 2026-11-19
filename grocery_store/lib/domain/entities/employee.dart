/// Link between a user (Firebase Auth UID) and the single store they work in.
///
/// Stored in `employees/{uid}`: using the UID as document id guarantees that
/// an employee can belong to at most one store.
class Employee {
  final String uid;
  final String storeId;
  final String name;
  final String email;

  /// Invitation code used to join (audit / validated by the security rules).
  final String invitationCode;
  final DateTime createdAt;

  Employee({
    required this.uid,
    required this.storeId,
    this.name = '',
    this.email = '',
    this.invitationCode = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'name': name,
      'email': email,
      'invitationCode': invitationCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Employee.fromJson(String uid, Map<String, dynamic> json) {
    return Employee(
      uid: uid,
      storeId: json['storeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      invitationCode: json['invitationCode'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
