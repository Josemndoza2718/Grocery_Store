import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/add_product/add_product_page.dart';

class ProductsListWidget extends StatelessWidget {
  const ProductsListWidget({
    super.key,
    required this.listProducts,
    required this.onTap,
    required this.onPressed,
    required this.onClose,
    required this.isFilterList,
    this.moneyConversion,
    this.category,
    this.listProductsByCategory,
    required this.onDeleteProduct,
  });

  final List<Product>? listProducts;
  final List<Product>? listProductsByCategory;
  final Function(int) onTap;
  final Function(int) onPressed;
  final Function() onClose;
  final Function(int) onDeleteProduct;
  final double? moneyConversion;
  final String? category;
  final bool isFilterList;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: AppColors.lightwhite,
            borderRadius: BorderRadius.circular(10)),
        child: GridView.builder(
          scrollDirection: Axis.vertical,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            //mainAxisSpacing: 2,
            childAspectRatio: 0.75,
          ),
          itemCount: isFilterList
              ? listProductsByCategory!.length
              : listProducts!.length + 1,
          itemBuilder: (context, index) {
            if (index == listProducts?.length) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductPage(),
                    ),
                  ).then((_) {
                    onClose();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(115, 184, 184, 184),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle,
                        size: 40,
                      ),
                      Text(
                        "Add Product",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }
            return GestureDetector(
                onTap: () {
                  onTap(index);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductPage(
                        product: isFilterList
                            ? listProductsByCategory![index]
                            : listProducts![index],
                      ),
                    ),
                  ).then((_) {
                    onClose();
                  });
                },
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  showDialog(
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
                            onPressed: () {
                              onDeleteProduct(index);

                              /* viewModel
                                    .deleteCategory(listCategories![index].id); */
                              Navigator.of(context).pop();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(115, 184, 184, 184),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        //height: 100,
                        padding: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.green),
                        child: Container(
                          //height: 70,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.darkgreen),
                          child: Center(
                            child: Image.file(
                              File(isFilterList
                                  ? listProductsByCategory![index].image
                                  : listProducts![index].image),
                              height: 80,
                              width: 80,
                              //fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          isFilterList
                              ? listProductsByCategory![index].name
                              : listProducts![index].name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      /* Text(
                              "description: ${listProducts![index].description}",
                              style: const TextStyle(fontSize: 12),
                            ), */
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "${isFilterList ? listProductsByCategory![index].stockQuantity : listProducts![index].stockQuantity} und.",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${isFilterList ? listProductsByCategory![index].price : listProducts![index].price}\$",
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                Text(
                              "${(isFilterList 
                              ? listProductsByCategory![index].price 
                              : (listProducts![index].price) * (moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => onPressed(index),
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
                )
                );
          },
        ),
      ),
    );
  }
}
