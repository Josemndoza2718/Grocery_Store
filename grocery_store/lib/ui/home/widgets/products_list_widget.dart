import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/add_product_page.dart';

class ProductsListWidget extends StatelessWidget {
  const ProductsListWidget({
    super.key,
    required this.listProducts,
    required this.onClose,
    required this.isFilterList,
    this.moneyConversion,
    this.category,  this.listProductsByCategory, required this.onDeleteProduct,
  });

  final List<Product>? listProducts;
  final List<Product>? listProductsByCategory;
  final Function() onClose;
  final Function(int) onDeleteProduct;
  final double? moneyConversion;
  final String? category;
  final bool isFilterList;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        //height: MediaQuery.of(context).size.height * 0.3,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        //padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.lightwhite,
            borderRadius: BorderRadius.circular(10)),
        child: GridView.builder(
          scrollDirection: Axis.vertical,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            //mainAxisSpacing: 2,
            childAspectRatio: 0.8,
          ),
          itemCount: isFilterList ? (listProductsByCategory!.length)  : listProducts!.length + 1,
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
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => AddProductPage(
                      product: isFilterList ? listProductsByCategory![index] : listProducts![index],
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(115, 184, 184, 184), 
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: isFilterList ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.file(
                                File(listProductsByCategory![index].image),
                                height: 80,
                                width: 80,
                                //fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              listProductsByCategory![index].name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "description: ${listProductsByCategory![index].description}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "${listProductsByCategory![index].stockQuantity} und.",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${listProductsByCategory![index].price}\$ / ${(listProductsByCategory![index].price) * (moneyConversion ?? 0)}bs",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        )
                        :Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.file(
                                File(listProducts![index].image),
                                height: 80,
                                width: 80,
                                //fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              listProducts![index].name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "description: ${listProducts![index].description}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "${listProducts![index].stockQuantity} und.",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${listProducts![index].price}\$ / ${(listProducts![index].price) * (moneyConversion ?? 0)}bs",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                /* :listProducts![index].category == category
                    ? Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(115, 184, 184, 184), 
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.file(
                                File(listProducts![index].image),
                                height: 80,
                                width: 80,
                                //fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              listProducts![index].name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "description: ${listProducts![index].description}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "${listProducts![index].stockQuantity} und.",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${listProducts![index].price}\$ / ${(listProducts![index].price) * (moneyConversion ?? 0)}bs",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container() */
                    );
          },
        ),
      ),
    );
  }
}
