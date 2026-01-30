import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/extension.dart';

class CheckWidget extends StatelessWidget {
  final Cart? cart;
  final double subToTal;
  final double iva;
  final double discount;
  final double delivery;
  final double total;
  final double? moneyConversion;
  final Function() onTap;

  const CheckWidget({
    super.key,
    this.moneyConversion,
    required this.cart,
    required this.subToTal,
    this.iva = 0,
    this.discount = 0,
    this.delivery = 0,
    this.total = 0,
    required this.onTap,
  });

  double getTotal() {
    double total = 0;
    double subTotal = subToTal * moneyConversion!;
    double ivaTotal = subTotal * (iva / 100);
    double deliveryTotal = delivery * moneyConversion!;
    double preDiscountTotal = discount / 100;
    double discountTotal = (preDiscountTotal * subTotal);

    total = subTotal + ivaTotal + deliveryTotal - discountTotal;

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "lbl_check_resume".translate,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                GestureDetector(
                  onTap: () => onTap(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child:
                        const Icon(Icons.clear_rounded, color: AppColors.white),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${"lbl_name".translate}: ${cart?.ownerCarName ?? 'N/A'}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart?.products.length ?? 0,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cart!.products[index].name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  "${cart!.products[index].quantityToBuy.toStringAsFixed(0)} X ${((cart!.products[index].price) * (moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "lbl_subtotal".translate,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  "${(subToTal * (moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${"lbl_iva".translate}($iva%)",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  "${((subToTal * (moneyConversion ?? 0)) * (iva / 100)).toStringAsFixed(2)}bs",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${"lbl_discount".translate} ($discount%)",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  "${((subToTal * (moneyConversion ?? 0)) * (discount / 100)).toStringAsFixed(2)}bs",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "lbl_delivery".translate,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  "${(delivery * moneyConversion!).toStringAsFixed(2)}bs",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "lbl_total".translate,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  "${getTotal().toStringAsFixed(2)}bs",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
