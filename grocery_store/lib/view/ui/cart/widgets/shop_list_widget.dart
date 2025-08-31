import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/view/ui/view_model/cart_view_model.dart';
import 'package:provider/provider.dart';

class ShopListWidget extends StatefulWidget {
  const ShopListWidget({
    super.key,
    this.isActivePanel = const [],
    this.moneyConversion,
    this.payProduct = 0,
    required this.listCarts,
    required this.listProducts,
    required this.onDeleteProduct,
    required this.onAddProduct,
    required this.onRemoveProduct,
    required this.onTapPanel,
    required this.onRemoveCart,
    required this.onSetQuantityProduct,
    //required this.onSetTap,
    required this.onChanged,
    required this.onSetPayProduct,
  });

  final List<Cart>? listCarts;
  final List<Product>? listProducts;
  final Function(int, int) onDeleteProduct;
  final double? moneyConversion;
  final int payProduct;
  final Function(String) onAddProduct;
  final Function(String) onRemoveProduct;
  final Function(int) onTapPanel;
  final Function(int) onRemoveCart;
  final Function(int, double) onSetQuantityProduct;
  //final Function(int, String?) onSetTap;
  final Function(String, String) onChanged;
  final Function(int, int) onSetPayProduct;
  final List<bool> isActivePanel;

  @override
  State<ShopListWidget> createState() => _ShopListWidgetState();
}

class _ShopListWidgetState extends State<ShopListWidget> {
  final Map<String, TextEditingController> _quantityControllers = {};
  bool isPayment = false;
  late CartViewModel viewModel;

  @override
  void initState() {
    super.initState();
    //print("initState de ShopListWidget se ejecutó");
    // Inicializa los controladores solo una vez.
    // Accede al provider en initState, pero asegúrate de que esté disponible en el contexto.
    // Esto se hace con un pequeño truco de post-frame callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel = Provider.of<CartViewModel>(context, listen: false);
      for (Cart element in widget.listCarts ?? []) {
        for (var product in element.products) {
          _quantityControllers[product.id.toString()] =
              TextEditingController(text: product.quantity.toString());
        }
      }
      viewModel.addListener(_onProductProviderChanged);
    });
  }

  @override
  void didUpdateWidget(covariant ShopListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Solo actualiza si los carts cambiaron
    if (widget.listCarts != oldWidget.listCarts) {
      for (Cart cart in widget.listCarts ?? []) {
        for (Product product in cart.products) {
          final key = product.id.toString();
          // Solo crea el controlador si no existe
          if (!_quantityControllers.containsKey(key)) {
            _quantityControllers[key] = TextEditingController(
              text: product.quantity.toString(),
            );
          } else {
            // Actualiza el texto si es diferente
            if (_quantityControllers[key]?.text !=
                product.quantity.toString()) {
              _quantityControllers[key]?.text = product.quantity.toString();
            }
          }
        }
      }
    }
  }

  void _onProductProviderChanged() {
    // Este método se llamará cada vez que notifyListeners() sea invocado en ProductProvider
    for (Cart element in widget.listCarts ?? []) {
      for (Product product in element.products) {
        // Solo actualiza el controlador si el valor del modelo es diferente para evitar loops infinitos
        if (_quantityControllers[product.id.toString()]?.text !=
            product.quantity.toString()) {
          _quantityControllers[product.id.toString()]?.text =
              product.quantity.toString();
          // Mueve el cursor al final para mejor UX si el valor cambia
          _quantityControllers[product.id.toString()]?.selection =
              TextSelection.fromPosition(
                  TextPosition(offset: product.quantity.toString().length));
        }
      }
    }
  }

  @override
  void dispose() {
    // Es importante liberar los controladores y remover el listener
    viewModel.removeListener(_onProductProviderChanged);
    _quantityControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          child: ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) =>
                widget.onTapPanel(panelIndex),
            children: widget.listCarts!.map<ExpansionPanel>((Cart cart) {
              return ExpansionPanel(
                backgroundColor: AppColors.white,
                canTapOnHeader: true,
                isExpanded: widget.isActivePanel.length >
                        widget.listCarts!.indexOf(cart)
                    ? widget.isActivePanel[widget.listCarts!.indexOf(cart)]
                    : false,
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    leading: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 50,
                      color: Colors.black,
                    ),
                    title: Text(
                      cart.ownerCarName ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text("#${cart.id}"),
                  );
                },
                body: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16),
                    child: Expanded(
                      child: Column(
                        children: [
                          //Buttons DPP
                          Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    widget.onRemoveCart(cart.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isPayment = !isPayment;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Payment",
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          //Payment Options
                          if (isPayment)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      widget.onSetPayProduct(cart.id, 2),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.yellow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text("2 parts"),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      widget.onSetPayProduct(cart.id, 4),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.yellow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text("4 parts"),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      widget.onSetPayProduct(cart.id, 6),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.yellow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text("6 parts"),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      widget.onSetPayProduct(cart.id, 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.yellow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text("8 parts"),
                                  ),
                                ),
                              ],
                            ),
                          if (isPayment) const SizedBox(height: 8),
                          if (isPayment)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text("10 parts"),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text("12 parts"),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text("Direct Payment"),
                                ),
                              ],
                            ),
                          //Cards Products
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cart.products.length,
                            itemBuilder: (context, index) {
                              final product = cart.products[index];

                              return Container(
                                padding: const EdgeInsets.all(8),
                                child: Flexible(
                                  child: Column(spacing: 8, children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          border: const Border(
                                            bottom: BorderSide(
                                              width: 6,
                                              color: AppColors.ultralightgrey,
                                            ),
                                            right: BorderSide(
                                              width: 6,
                                              color: AppColors.ultralightgrey,
                                            ),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.white),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          //Product Image
                                          Container(
                                            height: 100,
                                            width: 90,
                                            //padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              //color: AppColors.darkgreen,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                File(product.image),
                                                height: double.infinity,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          //Product Data
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  //Title
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        product.name,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          widget
                                                              .onDeleteProduct(
                                                                  cart.id,
                                                                  product.id);
                                                        },
                                                        child: const Icon(
                                                          Icons.delete_forever,
                                                          color: AppColors.red,
                                                          //size: 30,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  //Description
                                                  Text(
                                                    product.description,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                  Text(
                                                    "${product.id}",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  Text(
                                                    "${product.price.toStringAsFixed(2)}\$",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "${((product.price) * (widget.moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    spacing: 8,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () => widget
                                                            .onRemoveProduct(
                                                                product.id
                                                                    .toString()),
                                                        child: const Icon(
                                                          Icons.remove_circle,
                                                          color: AppColors
                                                              .darkgreen,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 50,
                                                        child: TextFormField(
                                                          controller:
                                                              _quantityControllers[
                                                                  product.id
                                                                      .toString()],
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration:
                                                              InputDecoration(
                                                            //hintText: "0.0",
                                                            enabled: true,
                                                            isCollapsed: true,
                                                            filled: true,
                                                            fillColor: Colors
                                                                .transparent, //AppColors.lightgrey,
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                width: 2,
                                                                color: AppColors
                                                                    .green,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            disabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          /* onFieldSubmitted:
                                                              (value) {
                                                            if (value != "0.0" && value !="") {
                                                              widget.onSetQuantityProduct(cart.products[index].id, double.parse(value));
                                                            }
                                                          }, */
                                                          onChanged: (value) {
                                                            widget.onChanged(
                                                              value,
                                                              product.id
                                                                  .toString(),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          widget.onAddProduct(
                                                              product.id
                                                                  .toString());
                                                          //_quantityControllers[product.id]?.text = product.quantity.toString();
                                                        },
                                                        child: const Icon(
                                                          Icons.add_circle,
                                                          color: AppColors
                                                              .darkgreen,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ]),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
