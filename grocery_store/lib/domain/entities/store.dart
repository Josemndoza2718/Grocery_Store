/// A store: the root of an independent "universe" of data (products,
/// clients, carts, sales) shared by its owner and employees.
class Store {
  final String id;
  final String name;
  final String description;

  /// Firebase Auth UID of the owner.
  final String ownerId;

  /// Tax percentage applied at checkout (e.g. 16 = 16 %).
  final double iva;

  /// Bs per USD conversion rate in use.
  final double exchangeRate;

  /// Archived stores are hidden and read-only (stores are never deleted).
  final bool archived;

  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.id,
    required this.name,
    this.description = '',
    required this.ownerId,
    this.iva = 0,
    this.exchangeRate = 0,
    this.archived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'iva': iva,
      'exchangeRate': exchangeRate,
      'archived': archived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      iva: (json['iva'] as num?)?.toDouble() ?? 0,
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 0,
      archived: json['archived'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Store copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    double? iva,
    double? exchangeRate,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      iva: iva ?? this.iva,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
