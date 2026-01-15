import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/resource/images.dart';
import 'package:grocery_store/core/utils/extension.dart';
import 'package:grocery_store/ui/view_model/old/cart_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ShopListWidget extends StatefulWidget {
  final List<Cart>? listCarts;
  final List<Product>? listProducts;
  final Function(String, String) onDeleteProduct;
  final double moneyConversion;
  final int payProduct;
  final Function(String, String) onAddProduct;
  final Function(String, String) onRemoveProduct;
  final Function(int) onTapPanel;
  final Function(String) onRemoveCart;
  final Function(String) onPaymentCart;
  final Function(int, int) onSetQuantityProduct;
  final Function(String, String, String) onChanged;
  final Function(String, int) onSetPayProduct;
  final List<bool> isActivePanel;

  const ShopListWidget({
    super.key,
    this.isActivePanel = const [],
    this.moneyConversion = 0,
    this.payProduct = 0,
    required this.listCarts,
    required this.listProducts,
    required this.onDeleteProduct,
    required this.onAddProduct,
    required this.onRemoveProduct,
    required this.onTapPanel,
    required this.onRemoveCart,
    required this.onPaymentCart,
    required this.onSetQuantityProduct,
    required this.onChanged,
    required this.onSetPayProduct,
  });

  @override
  State<ShopListWidget> createState() => _ShopListWidgetState();
}

class _ShopListWidgetState extends State<ShopListWidget> {
  final Map<String, TextEditingController> _quantityControllers = {};
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
          final key = "${element.id}_${product.id}";
          _quantityControllers[key] = TextEditingController(
              text: (product.quantityToBuy).toString());
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
          final key = "${cart.id}_${product.id}";
          // Solo crea el controlador si no existe
          if (!_quantityControllers.containsKey(key)) {
            _quantityControllers[key] = TextEditingController(
              text: (product.quantityToBuy).toString(),
            );
          } else {
            // Actualiza el texto si es diferente
            if (_quantityControllers[key]?.text !=
                (product.quantityToBuy).toString()) {
              _quantityControllers[key]?.text =
                  (product.quantityToBuy).toString();
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
        final key = "${element.id}_${product.id}";
        // Solo actualiza el controlador si el valor del modelo es diferente para evitar loops infinitos
        if (_quantityControllers[key]?.text !=
            product.quantityToBuy.toString()) {
          _quantityControllers[key]?.text =
              product.quantityToBuy.toString();
          // Mueve el cursor al final para mejor UX si el valor cambia
          _quantityControllers[key]?.selection =
              TextSelection.fromPosition(TextPosition(
                  offset: product.quantityToBuy.toString().length));
        }
      }
    }
  }

  String _getTotalPriceCart(String cartId) {
    double totalPrice = 0;

    for (Cart cart in widget.listCarts ?? []) {
      if (cart.id == cartId) {
        totalPrice += cart.products
            .map((product) =>
                product.price *
                double.parse(
                    _quantityControllers["${cart.id}_${product.id}"]?.text ?? "0"))
            .reduce((a, b) => a + b);
      }
    }
    return (totalPrice * widget.moneyConversion).toStringAsFixed(2);
  }

  int _getTotalItemsCart(String cartId) {
    int totalItems = 0;
    for (Cart cart in widget.listCarts ?? []) {
      if (cart.id == cartId) {
        totalItems += cart.products
            .map((product) => int.parse(
                _quantityControllers["${cart.id}_${product.id}"]?.text ?? "0"))
            .reduce((a, b) => a + b);
      }
    }
    return totalItems;
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
                      subtitle: Text("#${DateFormat('yyyyMMdd').format(cart.createdAt)}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${'lbl_total_items'.translate}: ${_getTotalItemsCart(cart.id)}",
                          ),
                          Text("${'lbl_total'.translate}: ${_getTotalPriceCart(cart.id)} Bs"),
                        ],
                      ));
                },
                body: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                                  onPressed: () => widget.onRemoveCart(cart.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "lbl_delete_cart".translate,
                                    style: const TextStyle(color: AppColors.white),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => widget.onPaymentCart(cart.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "lbl_pay_cart".translate,
                                    style: const TextStyle(color: AppColors.white),
                                  ),
                                ),
                              ),
                              /* GestureDetector(
                                onTap: () => widget.onPaymentCart(cart.id),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.share, color: AppColors.white),
                                ),
                              ) */
                            ],
                          ),
                          const SizedBox(height: 8),
                          //Payment Options
                          /* if (isPayment)
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
                            ), */
                          //if (isPayment) const SizedBox(height: 8),
                          /* if (isPayment)
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
                                GestureDetector(
                                  onTap: () =>
                                      widget.onSetPayProduct(cart.id, 0),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.green,
                                      border: Border.all(
                                          color: AppColors.lightgrey, width: 4),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      "Direct Payment",
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ), */
                          //Cards Products
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cart.products.length,
                            itemBuilder: (context, index) {
                              final product = cart.products[index];

                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        //Product Image
                                        Container(
                                          height: 150,
                                          width: 150, //double.infinity,
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
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  AppImages.imageNotFound,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        //Product Data
                                        Expanded(
                                          child: Container(
                                            height: 160,
                                            padding: const EdgeInsets.all(8),
                                            //color: AppColors.orange,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                //Title
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                        widget.onDeleteProduct(
                                                          cart.id,
                                                          product.id,
                                                        );
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
                                                /* if (product.description.isNotEmpty)
                                                  Text(
                                                    product.description,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ), */
                                                /* Text(
                                                  "${product.id}",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ), */
                                                Text(
                                                  "${'lbl_\$_uni'.translate}: ${product.price.toStringAsFixed(2)}\$",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                                Text(
                                                  "${'lbl_bs_uni'.translate}: ${((product.price) * (widget.moneyConversion)).toStringAsFixed(2)}bs",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                                const Divider(
                                                  height: 8,
                                                  color: AppColors.grey,
                                                  thickness: 1,
                                                ),
                                                Text(
                                                  "${'lbl_total'.translate}: ${((product.price * int.parse(_quantityControllers["${cart.id}_${product.id}"]?.text ?? "0")) * (widget.moneyConversion)).toStringAsFixed(2)}bs",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const Spacer(),
                                                //Quantity
                                                Row(
                                                  spacing: 8,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () => widget.onRemoveProduct(product.id.toString(), cart.id),
                                                      child: const Icon(
                                                        Icons.remove_circle,
                                                        color: AppColors.darkgreen,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 50,
                                                      child: TextFormField(
                                                        controller: _quantityControllers["${cart.id}_${product.id}"],
                                                        keyboardType: TextInputType.number,
                                                        textAlign: TextAlign.center,
                                                        decoration: InputDecoration(
                                                          enabled: true,
                                                          isCollapsed: true,
                                                          filled: true,
                                                          fillColor: Colors.transparent,
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: const BorderSide(
                                                              width: 2,
                                                              color: AppColors.green,
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
                                                        onChanged: (value) => widget.onChanged(value, product.id.toString(), cart.id),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => widget.onAddProduct(product.id.toString(), cart.id),
                                                      child: const Icon(
                                                        Icons.add_circle,
                                                        color:
                                                            AppColors.darkgreen,
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
                                  ),
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
