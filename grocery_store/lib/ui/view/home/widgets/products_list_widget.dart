import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/resource/custom_dialgos.dart';
import 'package:grocery_store/core/resource/images.dart';
import 'package:grocery_store/core/resource/my_localizations.dart';
import 'package:grocery_store/ui/view/add_product/add_product_page.dart';

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
            childAspectRatio: isPayMode ? 1.2 : 0.60,
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
                          Navigator.pop(context);
                        },
                      );
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
                              child: listProducts![index].image.isEmpty
                                  ? const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 50,
                                      color: AppColors.green,
                                    )
                                  : Image.file(
                                      File(listProducts![index].image),
                                      // height: 80,
                                      // width: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 50,
                                          color: AppColors.green,
                                        );
                                      },
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
                              "${"${listProducts![index].quantityToBuy}"} ${setselectedMeasurements(int.parse(listProducts![index].idStock))}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                    //Products List
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
                            height: 150,
                            width: double.infinity,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                //border: Border.all(color: AppColors.green, width: 4),
                                color: AppColors.transparent),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:  Image.file(
                                      File(listProducts![index].image),
                                      // height: 100,
                                      // width: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          AppImages.imageNotFound,
                                          fit: BoxFit.cover,
                                        );
                                      },
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
                          /* Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              listProducts![index].description.isEmpty
                                  ? ""
                                  : "Description: ${listProducts![index].description}",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ), */
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Cantidad: ${listProducts![index].stockQuantity}",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          /* Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "${"${listProducts![index].stockQuantity}"} ${setselectedMeasurements(int.parse(listProducts![index].idStock))}",
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ), */
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Precio: ${((listProducts![index].price.toStringAsFixed(2)))}\$",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Precio: ${(((listProducts![index].price) * (moneyConversion ?? 0)).toStringAsFixed(2))}bs",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    onPressed(index);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      (Icons.add),
                                      color: AppColors.white,
                                      size: 40,
                                    ),
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
