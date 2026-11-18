import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/core/errors/failure.dart';
import 'package:grocery_store/core/errors/firebase_error_handler.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/use_cases/sales/process_payment_use_case.dart';

/// Thrown inside the transaction to abort it when stock is not valid.
class _StockException implements Exception {
  final String message;
  const _StockException(this.message);
}

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({required this.storeId});

  final String storeId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _store =>
      _db.collection('stores').doc(storeId);

  @override
  Future<Result<void>> processPayment(Cart cart, Cart sale) async {
    // Group the quantities per product (defensive: a product could appear twice).
    final Map<String, int> quantities = {};
    final Map<String, String> names = {};
    for (final product in cart.products) {
      if (product.quantityToBuy > 0) {
        quantities[product.id] =
            (quantities[product.id] ?? 0) + product.quantityToBuy;
        names[product.id] = product.name;
      }
    }

    if (quantities.isEmpty) {
      return const Error(
        StockFailure(
          message: 'El carrito no tiene productos con cantidad a cobrar',
          code: 'empty-cart',
        ),
      );
    }

    // Set when the transaction is aborted for stock reasons. Kept in a local
    // variable because the error thrown inside the transaction may be wrapped
    // by the plugin/guard before reaching us.
    String? stockError;

    final result = await FirebaseErrorHandler.guard(() async {
      await _db.runTransaction((transaction) async {
        // Firestore may retry the handler on contention: start each attempt clean.
        stockError = null;
        final productRefs = {
          for (final id in quantities.keys)
            id: _store.collection('products').doc(id),
        };

        // 1. Read the CURRENT stock of every product (all reads before writes).
        final Map<String, int> newStocks = {};
        for (final entry in productRefs.entries) {
          final snapshot = await transaction.get(entry.value);
          final name = names[entry.key] ?? entry.key;

          if (!snapshot.exists) {
            stockError = 'El producto "$name" ya no existe';
            throw _StockException(stockError!);
          }

          final currentStock =
              (snapshot.data()?['stockQuantity'] as num?)?.toInt() ?? 0;
          final requested = quantities[entry.key]!;

          if (requested > currentStock) {
            stockError = 'Stock insuficiente para "$name": '
                'disponible $currentStock, solicitado $requested';
            throw _StockException(stockError!);
          }
          newStocks[entry.key] = currentStock - requested;
        }

        // 2. Update stock based on the real values read above. Only the
        //    stock field changes: the rules let employees DECREASE it only.
        for (final entry in newStocks.entries) {
          transaction.update(
            productRefs[entry.key]!,
            {'stockQuantity': entry.value},
          );
        }

        // 3. Create the sale (immutable) with the checkout data.
        transaction.set(
          _store.collection('sales').doc(cart.id),
          sale.toJson(),
        );

        // 4. Delete the active cart.
        transaction.delete(_store.collection('carts').doc(cart.id));
      });
    });

    if (stockError != null) {
      return Error(StockFailure(message: stockError!));
    }
    return result;
  }
}
