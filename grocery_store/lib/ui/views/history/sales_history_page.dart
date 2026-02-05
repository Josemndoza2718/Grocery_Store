import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/extension.dart';
import 'package:grocery_store/ui/view_model/providers/sales_history_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SalesHistoryPage extends StatelessWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("lbl_history_sales".translate, style: Theme.of(context).textTheme.displaySmall,),
        centerTitle: false,
        backgroundColor: AppColors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<SalesHistoryViewModel>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final salesList = provider.sales;

          if (salesList.isEmpty) {
            return Center(
              child: Text(
                "lbl_no_sales".translate,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: salesList.length,
            itemBuilder: (context, index) {
              final cart = salesList[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Theme.of(context).cardColor,
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
                            style: Theme.of(context).textTheme.bodyLarge,
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
                              "lbl_paid".translate,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${"lbl_date".translate}: ${DateFormat('dd/MM/yyyy HH:mm').format(cart.updatedAt)}",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${cart.products.length} ${"lbl_sales_products".translate}",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            "${"lbl_total".translate}: ${_calculateTotal(cart, provider.moneyConversion).toStringAsFixed(2)}bs",
                            style: Theme.of(context).textTheme.bodyLarge,
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

    if (moneyConversion == 0 ) {
      return total;
    }
    return total * moneyConversion;
  }
}
