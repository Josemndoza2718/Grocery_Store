import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/widgets/FloatingMessage.dart';

class ShopListWidget extends StatelessWidget {
  ShopListWidget({
    super.key,
    this.isActiveList = const [],
    this.moneyConversion,
    required this.listProducts,
    required this.onDeleteProduct,
    required this.onAddProduct,
    required this.onRemoveProduct,
    required this.onTap,
    required this.onSetTap,
  });

  final List<Product>? listProducts;
  final Function(int) onDeleteProduct;
  final double? moneyConversion;
  final Function(int) onAddProduct;
  final Function(int) onRemoveProduct;
  final Function(int) onTap;
  final Function(int, String?) onSetTap;
  final List<bool> isActiveList;

  final Map<int, TextEditingController> quantityController = {};

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Esto quita el foco de cualquier TextField
        behavior: HitTestBehavior.opaque,
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
              quantityController[index] ??= TextEditingController();
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
                        color: AppColors.black.withAlpha((0.1 * 255).toInt()),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
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
                                    onTap: () {
                                      onDeleteProduct(index);
                                      showFloatingMessage(
                                          context: context,
                                          message: "Product deleted to cart",
                                          color: AppColors.red);
                                    },
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
                                    "${listProducts![index].stockQuantity}",
                                    style: const TextStyle(fontSize: 14),
                                  ), */
                              Text(
                                "${listProducts![index].price.toStringAsFixed(2)}\$",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${((listProducts![index].price) * (moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Row(
                                spacing: 8,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  isActiveList[index]
                                      ? GestureDetector(
                                          onTap: () => onTap(index),
                                          child: const Icon(
                                            Icons.close,
                                            color: AppColors.red,
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () => onRemoveProduct(index),
                                          child: const Icon(
                                            Icons.remove_circle,
                                            color: AppColors.darkgreen,
                                          ),
                                        ),
                                  !isActiveList[index]
                                      ? GestureDetector(
                                          onTap: () { 
                                            onTap(index);},
                                          child: Text(
                                              "${quantityController[index]!.text.isEmpty
                                              ? listProducts![index].quantity.toStringAsFixed(0)
                                              : quantityController[index]?.text}"),
                                        )
                                      : SizedBox(
                                          width: 100,
                                          child: TextFormField(
                                            controller: quantityController[index],
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              hintText: "Add quantity",
                                              hintStyle: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              enabled: true,
                                              isCollapsed: true,
                                              filled: true,
                                              fillColor: AppColors.lightwhite,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: AppColors.green,
                                                  width: 4,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onChanged: (value) {},
                                          ),
                                        ),
                                  !isActiveList[index]
                                      ? GestureDetector(
                                          onTap: () {
                                            onAddProduct(index);
                                            //onSetTap(index, null);
                                          },
                                          child: const Icon(
                                            Icons.add_circle,
                                            color: AppColors.darkgreen,
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            if (quantityController[index]?.text !=null &&
                                                (int.parse(quantityController[index]!.text) <= listProducts![index].stockQuantity)) {
                                              onSetTap(index, quantityController[index]!.text);
                                              onTap(index);
                                            } else {
                                              quantityController[index]?.clear();
                                              showFloatingMessage(
                                                  context: context,
                                                  message:
                                                      "Quantity is greater than stock ${listProducts![index].stockQuantity}",
                                                  color: AppColors.red);
                                            }
                                          },
                                          child: const Icon(
                                            Icons.check,
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
      ),
    );
  }
}
