import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/extension.dart';

class CheckWidget extends StatelessWidget {
  final Cart? cart;
  final bool isPaid;
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
    this.isPaid = false,
    required this.cart,
    required this.subToTal,
    this.iva = 0,
    this.discount = 0,
    this.delivery = 0,
    this.total = 0,
    required this.onTap,
  });

  double getTotal() {
    double total;
    double subTotal;
    double ivaTotal;
    double deliveryTotal;
    double preDiscountTotal;
    double discountTotal;

    if (moneyConversion != null) {
      double total = 0;
      double subTotal = subToTal * moneyConversion!;
      double ivaTotal = subTotal * (iva / 100);
      double deliveryTotal = delivery * moneyConversion!;
      double preDiscountTotal = discount / 100;
      double discountTotal = (preDiscountTotal * subTotal);

      total = subTotal + ivaTotal + deliveryTotal - discountTotal;

      return total;
    }

    subTotal = subToTal;
    ivaTotal = subTotal * (iva / 100);
    deliveryTotal = delivery;
    preDiscountTotal = discount / 100;
    discountTotal = (preDiscountTotal * subTotal);

    total = subTotal + ivaTotal + deliveryTotal - discountTotal;

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10)),
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
                        child: const Icon(Icons.clear_rounded,
                            color: AppColors.white),
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
                      final product = cart!.products[index];
                      final price = product.price * moneyConversion!;
                      final priceBs = product.price * moneyConversion!;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      moneyConversion == null
                                          ? "${product.quantityToBuy.toStringAsFixed(0)} X ${price.toStringAsFixed(2)}\$"
                                          : "${product.quantityToBuy.toStringAsFixed(0)} X ${priceBs.toStringAsFixed(2)} Bs",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
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
                      moneyConversion == null
                          ? "${subToTal.toStringAsFixed(2)}\$"
                          : "${(subToTal * (moneyConversion ?? 0)).toStringAsFixed(2)} Bs",
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
                      moneyConversion == null
                          ? "${(subToTal * (iva / 100)).toStringAsFixed(2)}\$"
                          : "${((subToTal * (moneyConversion ?? 0)) * (iva / 100)).toStringAsFixed(2)} bs",
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
                      moneyConversion == null
                          ? "${(subToTal * (discount / 100)).toStringAsFixed(2)}\$"
                          : "${((subToTal * (moneyConversion ?? 0)) * (discount / 100)).toStringAsFixed(2)} bs",
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
                      moneyConversion == null
                          ? "${delivery.toStringAsFixed(2)}\$"
                          : "${(delivery * moneyConversion!).toStringAsFixed(2)} bs",
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
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      moneyConversion == null
                          ? "${getTotal().toStringAsFixed(2)}\$"
                          : "${getTotal().toStringAsFixed(2)} bs",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isPaid)
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 60,
          ),
      ],
    );
  }
}
