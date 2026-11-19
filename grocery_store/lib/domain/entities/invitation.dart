import 'dart:math';

/// Single-use code an owner shares so a person can join their store as an
/// employee. Stored in `invitations/{code}`.
class Invitation {
  /// How long a new invitation can be used.
  static const Duration validity = Duration(hours: 48);

  /// Characters used in codes: no 0/O, 1/I/L to avoid confusion.
  static const String alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  /// Length of a code without the separator (e.g. `K7M4QXPA`).
  static const int codeLength = 8;

  final String code;
  final String storeId;
  final String storeName;

  /// UID of the owner who created it.
  final String createdBy;
  final DateTime createdAt;
  final DateTime expiresAt;

  /// UID of the person who used it (`null` while pending).
  final String? usedBy;
  final DateTime? usedAt;

  Invitation({
    required this.code,
    required this.storeId,
    this.storeName = '',
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
    this.usedBy,
    this.usedAt,
  });

  bool get isUsed => usedBy != null;

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);

  bool isPending(DateTime now) => !isUsed && !isExpired(now);

  /// Code formatted for humans: `K7M4-QXPA`.
  String get displayCode => format(code);

  /// Generates a random code with a cryptographically secure generator.
  static String generateCode([Random? random]) {
    final rng = random ?? Random.secure();
    return List.generate(
      codeLength,
      (_) => alphabet[rng.nextInt(alphabet.length)],
    ).join();
  }

  /// Normalizes what a user typed: uppercase, without spaces or dashes.
  static String normalize(String input) =>
      input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static String format(String code) {
    final normalized = normalize(code);
    if (normalized.length <= 4) return normalized;
    return '${normalized.substring(0, 4)}-${normalized.substring(4)}';
  }

  /// Whether [code] (already normalized) has a valid shape.
  static bool isWellFormed(String code) =>
      code.length == codeLength &&
      code.split('').every((c) => alphabet.contains(c));
}
