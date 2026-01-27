import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/extension.dart';
import 'package:grocery_store/ui/view_model/old/cart_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesHistoryPage extends StatelessWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("lbl_sales_history".translate),
        backgroundColor: AppColors.green,
      ),
      body: Consumer<CartViewModel>(
        builder: (context, provider, _) {
          final paidCarts = provider.paidCarts.reversed.toList();

          if (paidCarts.isEmpty) {
            return Center(
              child: Text(
                "No hay ventas registradas",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: paidCarts.length,
            itemBuilder: (context, index) {
              final cart = paidCarts[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cart.ownerCarName ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.green),
                            ),
                            child: Text(
                              "PAGADO",
                              style: const TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(cart.updatedAt)}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${cart.products.length} productos",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "Total: ${_calculateTotal(cart, provider.moneyConversion).toStringAsFixed(2)}bs",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  double _calculateTotal(Cart cart, double moneyConversion) {
    double total = 0;
    for (var product in cart.products) {
      if (product.quantityToBuy > 0) {
        total += (product.price * product.quantityToBuy);
      }
    }
    return total * moneyConversion;
  }
}
