import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';

class ShopListWidget extends StatelessWidget {
  const ShopListWidget({
    super.key,
    required this.listProducts,
    this.moneyConversion,
    required this.onDeleteProduct, 
  });

  final List<Product>? listProducts;
  final Function(int) onDeleteProduct;
  final double? moneyConversion;

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
            crossAxisCount: 1,
            childAspectRatio: 2,
          ),
          itemCount: listProducts!.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.only(bottom: 5, right: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.ultralightgrey),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightwhite,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.darkgreen),
                      child: Center(
                        child: Image.file(
                          File(listProducts![index].image),
                          height: 80,
                          width: 80,
                          //fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  listProducts![index].name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () => onDeleteProduct(index),
                                  child: const Icon(
                                    Icons.delete_forever,
                                    color: AppColors.red,
                                    //size: 30,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              listProducts![index].description,
                              style: const TextStyle(fontSize: 14),
                            ),
                            /* Text(
                                  "${listProducts![index].stockQuantity} und.",
                                  style: const TextStyle(fontSize: 14),
                                ), */
                            Text(
                              "${listProducts![index].price}\$",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${(listProducts![index].price) * (moneyConversion ?? 0)}bs",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () => {},
                                  child: const Icon(
                                    Icons.remove_circle,
                                    color: AppColors.darkgreen,
                                  ),
                                ),
                                Text("${listProducts![index].stockQuantity}"),
                                GestureDetector(
                                  onTap: () => {},
                                  child: const Icon(
                                    Icons.add_circle,
                                    color: AppColors.darkgreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
          },
        ),
      ),
    );
  }
}
