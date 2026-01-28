import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/resource/custom_dialgos.dart';
import 'package:grocery_store/core/resource/images.dart';
import 'package:grocery_store/core/resource/my_localizations.dart';
import 'package:grocery_store/ui/views/add_product/add_product_page.dart';

class ProductsListWidget extends StatelessWidget {
  const ProductsListWidget({
    super.key,
    required this.listProducts,
    required this.onPressed,
    required this.onClose,
    this.moneyConversion,
    required this.onDeleteProduct,
  });

  
  final List<Product>? listProducts;
  final Function(int) onPressed;
  final Function() onClose;
  final Function(int) onDeleteProduct;
  final double? moneyConversion;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
            color: AppColors.lightwhite,
            borderRadius: BorderRadius.circular(10)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive values
            final double availableWidth = constraints.maxWidth;

            // For pay mode: horizontal scroll, fixed item width
            // For normal mode: calculate columns based on width
            int crossAxisCount;
            double childAspectRatio;

            // Calculate number of columns: minimum 2 columns, max 4
            crossAxisCount = (availableWidth / 180).floor().clamp(2, 4);
            // Adjust aspect ratio based on available space
            final double itemWidth = availableWidth / crossAxisCount;
            childAspectRatio =
                itemWidth / 340; // Height ~340px for product card

            return GridView.builder(
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: listProducts!.length,
              itemBuilder: (context, index) {
                final localizations = MyLocalizations.of(context);

                return GestureDetector(
                  onTap: () {
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
                  onLongPress: () {
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
                  child: //Products List
                      Container(
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
                              color: AppColors.transparent),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: listProducts![index].image.contains('http')
                            ? Image.network(
                              listProducts![index].image,
                              // height: 100,
                              // width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  AppImages.imageNotFound,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                            : Image.file(
                              File(listProducts![index].image),
                              // height: 100,
                              // width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Cantidad: ${listProducts![index].stockQuantity}",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal),
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
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                "Precio: ${(((listProducts![index].price) * (moneyConversion ?? 0)).toStringAsFixed(2))}bs",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
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
            );
          },
        ),
      ),
    );
  }
}
