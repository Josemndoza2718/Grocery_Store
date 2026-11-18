import 'package:grocery_store/domain/entities/product.dart';

/// A client's cart. Once paid, the same structure is stored as a sale in
/// `stores/{storeId}/sales` with the checkout amounts filled in.
class Cart {
  final String id;

  /// Legacy owner field (per-user model, before multi-store). Kept so old
  /// documents can still be read and migrated.
  final String userId;

  /// Id of the client the cart belongs to.
  final String ownerId;
  final String? ownerCarName;
  String status;
  int payPart;
  double total;
  int totalItems;
  final List<Product> products;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime? payAt;

  /// UID of the store member who created the cart.
  final String createdBy;

  // ── Checkout data (filled when the cart is paid) ──
  /// UID / name of the store member who charged the sale.
  final String soldBy;
  final String soldByName;

  /// Amounts in USD at the moment of the sale.
  final double subtotal;

  /// Percentages applied at checkout.
  final double iva;
  final double discount;

  /// Delivery cost in USD.
  final double delivery;

  /// Bs per USD rate used for the sale (0 if none was set).
  final double exchangeRate;

  Cart({
    required this.id,
    this.userId = '',
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
    this.createdBy = '',
    this.soldBy = '',
    this.soldByName = '',
    this.subtotal = 0,
    this.iva = 0,
    this.discount = 0,
    this.delivery = 0,
    this.exchangeRate = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Sum of price × quantity of the products with quantity > 0 (USD).
  double get productsSubtotal => products
      .where((p) => p.quantityToBuy > 0)
      .fold(0.0, (sum, p) => sum + p.price * p.quantityToBuy);

  /// Total in USD: the stored one for sales made with checkout data, or the
  /// products subtotal for legacy sales that did not store it.
  double get effectiveTotal => total > 0 ? total : productsSubtotal;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
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
      'createdBy': createdBy,
      'soldBy': soldBy,
      'soldByName': soldByName,
      'subtotal': subtotal,
      'iva': iva,
      'discount': discount,
      'delivery': delivery,
      'exchangeRate': exchangeRate,
    };
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    double toDouble(Object? value) => (value as num?)?.toDouble() ?? 0.0;

    return Cart(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      ownerId:
          json['ownerId']?.toString() ?? json['owner_id']?.toString() ?? '',
      ownerCarName:
          json['ownerCarName'] as String? ?? json['owner_car_name'] as String?,
      status: json['status'] as String? ?? 'pending',
      payPart: json['payPart'] as int? ?? 0,
      total: toDouble(json['total']),
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
      createdBy: json['createdBy'] as String? ?? '',
      soldBy: json['soldBy'] as String? ?? '',
      soldByName: json['soldByName'] as String? ?? '',
      subtotal: toDouble(json['subtotal']),
      iva: toDouble(json['iva']),
      discount: toDouble(json['discount']),
      delivery: toDouble(json['delivery']),
      exchangeRate: toDouble(json['exchangeRate']),
    );
  }

  Cart copyWith({
    String? id,
    String? userId,
    String? ownerId,
    String? ownerCarName,
    String? status,
    int? payPart,
    double? total,
    int? totalItems,
    List<Product>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? payAt,
    String? createdBy,
    String? soldBy,
    String? soldByName,
    double? subtotal,
    double? iva,
    double? discount,
    double? delivery,
    double? exchangeRate,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
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
      createdBy: createdBy ?? this.createdBy,
      soldBy: soldBy ?? this.soldBy,
      soldByName: soldByName ?? this.soldByName,
      subtotal: subtotal ?? this.subtotal,
      iva: iva ?? this.iva,
      discount: discount ?? this.discount,
      delivery: delivery ?? this.delivery,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }
}

/// Amounts applied when a cart is charged.
class CheckoutData {
  /// IVA percentage (e.g. 16).
  final double iva;

  /// Discount percentage over the subtotal.
  final double discount;

  /// Delivery cost in USD.
  final double delivery;

  /// Bs per USD rate in use.
  final double exchangeRate;

  const CheckoutData({
    this.iva = 0,
    this.discount = 0,
    this.delivery = 0,
    this.exchangeRate = 0,
  });

  /// Returns [cart] as a paid sale with the computed amounts (USD).
  Cart applyTo(
    Cart cart, {
    required String soldBy,
    required String soldByName,
    required DateTime now,
  }) {
    final subtotal = cart.productsSubtotal;
    final total = subtotal +
        subtotal * (iva / 100) +
        delivery -
        subtotal * (discount / 100);
    final items = cart.products.fold<int>(0, (sum, p) => sum + p.quantityToBuy);
    return cart.copyWith(
      status: 'paid',
      payAt: now,
      updatedAt: now,
      soldBy: soldBy,
      soldByName: soldByName,
      subtotal: subtotal,
      iva: iva,
      discount: discount,
      delivery: delivery,
      exchangeRate: exchangeRate,
      total: total < 0 ? 0 : total,
      totalItems: items,
    );
  }
}
