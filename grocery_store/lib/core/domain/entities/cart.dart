import 'package:grocery_store/core/domain/entities/product.dart';

class Cart {
  final String id;
  final int ownerId;
  final String? ownerCarName;
  String status;
  int payPart;
  double total;
  int totalItems;
  final List<Product> products;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime? payAt;

  Cart({
    required this.id,
    required this.ownerId,
    this.ownerCarName,
    this.status = 'pending',
    this.payPart = 0,
    this.total = 0,
    this.totalItems = 0,
    required this.products,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.payAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerCarName': ownerCarName,
      'status': status,
      'payPart': payPart,
      'total': total,
      'totalItems': totalItems,
      'products': products.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'payAt': payAt?.toIso8601String(),
    };
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String,
      ownerId: json['ownerId'] as int,
      ownerCarName: json['ownerCarName'] as String?,
      status: json['status'] as String? ?? 'pending',
      payPart: json['payPart'] as int? ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      totalItems: json['totalItems'] as int? ?? 0,
      products: (json['products'] as List<dynamic>?)
              ?.map((p) => Product.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      payAt: json['payAt'] != null
          ? DateTime.parse(json['payAt'] as String)
          : null,
    );
  }

  Cart copyWith({
    String? id,
    int? ownerId,
    String? ownerCarName,
    String? status,
    int? payPart,
    double? total,
    int? totalItems,
    List<Product>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? payAt,
  }) {
    return Cart(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerCarName: ownerCarName ?? this.ownerCarName,
      status: status ?? this.status,
      payPart: payPart ?? this.payPart,
      total: total ?? this.total,
      totalItems: totalItems ?? this.totalItems,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      payAt: payAt ?? this.payAt,
    );
  }
}
