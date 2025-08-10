import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/resource/custom_dialgos.dart';
import 'package:grocery_store/core/resource/my_localizations.dart';
import 'package:grocery_store/ui/add_product/add_product_page.dart';

class ProductsListWidget extends StatelessWidget {
  const ProductsListWidget({
    super.key,
    this.isPayMode = false,
    required this.listProducts,
    required this.onTap,
    required this.onPressed,
    required this.onClose,
    this.moneyConversion,
    required this.onDeleteProduct,
  });

  final bool isPayMode;
  final List<Product>? listProducts;
  final Function(int) onTap;
  final Function(int) onPressed;
  final Function() onClose;
  final Function(int) onDeleteProduct;
  final double? moneyConversion;

  String setselectedMeasurements(int? value) {
    switch (value) {
      case 0:
        return 'other';
      case 1:
        return 'lt';
      case 2:
        return 'item';
      case 3:
        return 'kg';
      default:
        return "other";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        height: isPayMode ? 250 : double.infinity,
        decoration: isPayMode
            ? BoxDecoration(
                color: AppColors.lightwhite,
                borderRadius: BorderRadius.circular(10))
            : null,
        child: GridView.builder(
          scrollDirection: isPayMode ? Axis.horizontal : Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: isPayMode ? 1.2 : 0.75,
          ),
          itemCount: listProducts!.length,
          itemBuilder: (context, index) {
            final localizations = MyLocalizations.of(context);

            return GestureDetector(
              onTap: isPayMode
                  ? null
                  : () {
                      onTap(index);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductPage(
                            product: listProducts![index],
                          ),
                        ),
                      ).then((_) {
                        onClose();
                      });
                    },
              onLongPress: isPayMode
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      CustomDialgos.showAlertDialog(
                        context: context,
                        title: localizations?.translate('title') ?? 'title',
                        onConfirm: () {
                          onDeleteProduct(index);
                          Navigator.of(context).pop();
                        },
                      );
                      /* showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Category'),
                            content: const Text(
                                'Are you sure you want to delete this category?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      ); */
                    },
              child: isPayMode
                  ? Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(115, 184, 184, 184),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              //color: AppColors.darkgreen,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(listProducts![index].image),
                                // height: 80,
                                // width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          //const SizedBox(height: 10),
                          /* Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(listProducts![index].name,
                              style: const TextStyle(
                                  fontSize: 12, 
                                  //fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ), */
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "${"${listProducts![index].quantity}"} ${setselectedMeasurements(listProducts![index].idStock)}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.transparent),
                            child: Container(
                              //height: 70,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  //border: Border.all(color: AppColors.green, width: 4),
                                  color: AppColors.white),
                              child: Center(
                                child: Image.file(
                                  File(listProducts![index].image),
                                  height: 100,
                                  width: 100,
                                  //fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          //const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              listProducts![index].name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          /* Text(
                              "description: ${listProducts![index].description}",
                              style: const TextStyle(fontSize: 12),
                            ), */
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "${"${listProducts![index].stockQuantity}"} ${setselectedMeasurements(listProducts![index].idStock)}",
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${((listProducts![index].price.toStringAsFixed(2)))}\$",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${(((listProducts![index].price) * (moneyConversion ?? 0)).toStringAsFixed(2))}bs",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    onPressed(index);
                                  },
                                  child: const Icon(
                                    (Icons.add_box),
                                    color: Colors.black,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
