import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/widgets/FloatingMessage.dart';

class ShopListWidget extends StatelessWidget {
  ShopListWidget({
    super.key,
    this.isActiveList = const [],
    this.isActivePanel = const [],
    this.moneyConversion,
    required this.listCarts,
    required this.listProducts,
    required this.onDeleteProduct,
    required this.onAddProduct,
    required this.onRemoveProduct,
    required this.onTap,
    required this.onTapPanel,
    required this.onRemoveCart,
    required this.onSetTap,
  });

  final List<Cart>? listCarts;
  final List<Product>? listProducts;
  final Function(int) onDeleteProduct;
  final double? moneyConversion;
  final Function(int) onAddProduct;
  final Function(int) onRemoveProduct;
  final Function(int) onTap;
  final Function(int) onTapPanel;
  final Function(int) onRemoveCart;
  final Function(int, String?) onSetTap;
  final List<bool> isActiveList;
  final List<bool> isActivePanel;

  final Map<int, TextEditingController> quantityController = {};

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          child: ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) => onTapPanel(panelIndex),
            children: List.generate(listCarts!.length, (index) {
              quantityController[index] ??= TextEditingController();

              final cart = listCarts![index];

              return ExpansionPanel(
                canTapOnHeader: true,
                isExpanded: isActivePanel[index],
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    leading: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          //color: AppColors.darkgreen,
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 50,
                          color: Colors.black,
                        )),
                    title: Text(
                      cart.ownerCarName ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(cart.id.toString()),
                  );
                },
                body: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16),
                    child: Column(
                      spacing: 8,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            
                            ElevatedButton(
                              onPressed: () {
                                onRemoveCart(index);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Delete", style: TextStyle(color: AppColors.white),),
                            ),
                            ElevatedButton(
                              onPressed: () {
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Payment", style: TextStyle(color: AppColors.white),),
                            ),
                            ElevatedButton(
                              onPressed: () {
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Pay", style: TextStyle(color: AppColors.white),),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.ultralightgrey),
                          child: Column(
                            children: List.generate(
                              listCarts![index].products.length,
                              (productIndex) => CardCartWidget(
                                index: index,
                                listProducts: listCarts![index].products,
                                onDeleteProduct: onDeleteProduct,
                                moneyConversion: moneyConversion,
                                isActiveList: isActiveList,
                                onTap: onTap,
                                onRemoveProduct: onRemoveProduct,
                                quantityController: quantityController,
                                onAddProduct: onAddProduct,
                                onSetTap: onSetTap,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class CardCartWidget extends StatelessWidget {
  const CardCartWidget({
    super.key,
    required this.index,
    required this.listProducts,
    required this.onDeleteProduct,
    required this.moneyConversion,
    required this.isActiveList,
    required this.onTap,
    required this.onRemoveProduct,
    required this.quantityController,
    required this.onAddProduct,
    required this.onSetTap,
  });

  final int index;
  final List<Product>? listProducts;
  final Function(int p1) onDeleteProduct;
  final double? moneyConversion;
  final List<bool> isActiveList;
  final Function(int p1) onTap;
  final Function(int p1) onRemoveProduct;
  final Map<int, TextEditingController> quantityController;
  final Function(int p1) onAddProduct;
  final Function(int p1, String? p2) onSetTap;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        onDeleteProduct(index);
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
                //const Spacer(),
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
                              onTap(index);
                            },
                            child: Text(
                                "${quantityController[index]!.text.isEmpty ? listProducts![index].quantity.toStringAsFixed(0) : quantityController[index]?.text}"),
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
                                fillColor: AppColors.lightgrey,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.green,
                                    width: 4,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
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
                              if (quantityController[index]?.text != null &&
                                  (int.parse(quantityController[index]!.text) <=
                                      listProducts![index].stockQuantity)) {
                                onSetTap(
                                    index, quantityController[index]!.text);
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
    );
  }
}
