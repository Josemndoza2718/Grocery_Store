import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/view_model/car_view_model.dart';
import 'package:provider/provider.dart';

class ShopListWidget extends StatefulWidget {
  ShopListWidget({
    super.key,
    this.isActivePanel = const [],
    this.moneyConversion,
    this.quantityProduct = 0.0,
    required this.listCarts,
    required this.listProducts,
    required this.onDeleteProduct,
    required this.onAddProduct,
    required this.onRemoveProduct,
    required this.onTapPanel,
    required this.onRemoveCart,
    required this.onSetQuantityProduct,
    required this.onSetTap,
    required this.onChanged,
  });

  final List<Cart>? listCarts;
  final List<Product>? listProducts;
  final Function(int) onDeleteProduct;
  final double? moneyConversion;
  final double quantityProduct;
  final Function(String) onAddProduct;
  final Function(String) onRemoveProduct;
  final Function(int) onTapPanel;
  final Function(int) onRemoveCart;
  final Function(int, double) onSetQuantityProduct;
  final Function(int, String?) onSetTap;
  final Function(String, String) onChanged;
  final List<bool> isActivePanel;

  @override
  State<ShopListWidget> createState() => _ShopListWidgetState();
}

class _ShopListWidgetState extends State<ShopListWidget> {
  final Map<String, TextEditingController> _quantityControllers = {};
  

  @override
  void initState() {
    super.initState();
    print("initState de ShopListWidget se ejecutó");
    // Inicializa los controladores solo una vez.
    // Accede al provider en initState, pero asegúrate de que esté disponible en el contexto.
    // Esto se hace con un pequeño truco de post-frame callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CarViewModel>(context, listen: false);
      for (Cart element in widget.listCarts ?? []) {
        for (var product in element.products) {
          _quantityControllers[product.id.toString()] =
              TextEditingController(text: product.quantity.toString());
        }
      }
      viewModel.addListener(_onProductProviderChanged);
    });
  }

 


  void _onProductProviderChanged() {
    // Este método se llamará cada vez que notifyListeners() sea invocado en ProductProvider
    for (Cart element in widget.listCarts ?? []) {
      for (Product product in element.products) {
        // Solo actualiza el controlador si el valor del modelo es diferente para evitar loops infinitos
        if (_quantityControllers[product.id.toString()]?.text != product.quantity.toString()) {
          _quantityControllers[product.id.toString()]?.text = product.quantity.toString();
          // Mueve el cursor al final para mejor UX si el valor cambia
          _quantityControllers[product.id.toString()]?.selection = TextSelection.fromPosition(
              TextPosition(offset: product.quantity.toString().length));
        }
      }
    }
  }

@override
  void dispose() {
    // Es importante liberar los controladores y remover el listener
    final viewModel = Provider.of<CarViewModel>(context, listen: false);
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
            expansionCallback: (panelIndex, isExpanded) => widget.onTapPanel(panelIndex),
            children: widget.listCarts!.map<ExpansionPanel>((Cart cart) {
              return ExpansionPanel(
                backgroundColor: AppColors.white,
                canTapOnHeader: true,
                isExpanded: true,
                /* (isActivePanel.length > index)
                    ? isActivePanel[index]
                    : false, */
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                    child: Expanded(
                      child: Column(
                        children: [
                          //Buttons DPP
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
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
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Payment",
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Pay",
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                            ],
                          ),
                          //Cards Products
                          Container(
                            height: 350,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cart.products.length,
                              itemBuilder: (context, index) {
                                final product = cart.products[index];
                          
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    spacing: 8, 
                                    children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          border: const Border(
                                            bottom: BorderSide(
                                              width: 6,
                                              color: AppColors
                                                  .ultralightgrey,
                                            ),
                                            right: BorderSide(
                                              width: 6,
                                              color: AppColors
                                                  .ultralightgrey,
                                            ),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.white),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          //Product Image
                                          Container(
                                            height: 100,
                                            width: 90,
                                            //padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10),
                                              //color: AppColors.darkgreen,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10),
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
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  //Title
                                                  Row(
                                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        product.name,
                                                        style:const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:FontWeight.bold,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          widget.onDeleteProduct(index);
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
                                                    style:const TextStyle(fontSize: 14),
                                                  ),
                                                  Text(
                                                    "${product.price.toStringAsFixed(2)}\$",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "${((product.price) * (widget.moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    spacing: 8,
                                                    mainAxisAlignment:MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () => widget.onRemoveProduct(product.id.toString()),
                                                        child: const Icon(
                                                          Icons.remove_circle,
                                                          color: AppColors.darkgreen,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 50,
                                                        child:TextFormField(
                                                          controller:  _quantityControllers[product.id.toString()],
                                                          keyboardType: TextInputType.number,
                                                          textAlign: TextAlign.center,
                                                          decoration: InputDecoration(
                                                            hintText: "0",
                                                            /* hintStyle: const TextStyle(
                                                                      fontSize: 12,
                                                                    ), */
                                                            enabled: true,
                                                            isCollapsed: true,
                                                            filled: true,
                                                            fillColor: Colors.transparent, //AppColors.lightgrey,
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                width: 2,
                                                                color: AppColors
                                                                    .green,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      10),
                                                            ),
                                                            disabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      10),
                                                            ),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                              borderRadius:
                                                                  BorderRadius.circular(
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
                                                            widget.onChanged( value, product.id.toString(),);
                                                          },
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          widget.onAddProduct(product.id.toString());
                                                          //_quantityControllers[product.id]?.text = product.quantity.toString();
                                                        },
                                                        child: const Icon(
                                                          Icons.add_circle,
                                                          color: AppColors.darkgreen,
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
                                );
                              },
                            ),
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

/* import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';

class ShopListWidget extends StatelessWidget {
  ShopListWidget({
    super.key,
    this.isActivePanel = const [],
    this.moneyConversion,
    required this.listCarts,
    required this.listProducts,
    required this.onDeleteProduct,
    required this.onAddProduct,
    required this.onRemoveProduct,
    required this.onTapPanel,
    required this.onRemoveCart,
    required this.onSetQuantityProduct,
    required this.onSetTap,
  });

  final List<Cart>? listCarts;
  final List<Product>? listProducts;
  final Function(int) onDeleteProduct;
  final double? moneyConversion;
  final Function(int) onAddProduct;
  final Function(int) onRemoveProduct;
  final Function(int) onTapPanel;
  final Function(int) onRemoveCart;
  final Function(int, double) onSetQuantityProduct;
  final Function(int, String?) onSetTap;
  final List<bool> isActivePanel;

  final Map<int, List<TextEditingController>> quantityController = {};

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          child: ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) =>
                onTapPanel(panelIndex),
            children: List.generate(listCarts!.length, (index) {
              //quantityController[index] ??= TextEditingController();
              final cart = listCarts![index];

              return ExpansionPanel(
                backgroundColor: AppColors.white,
                canTapOnHeader: true,
                isExpanded: (isActivePanel.length > index)
                    ? isActivePanel[index]
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
                        horizontal: 16.0, 
                        vertical: 16,
                        ),
                    child: Column(
                      children: [
                        //Buttons DPP
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
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Payment",
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Pay",
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            spacing: 8,
                            children:
                                List.generate(listCarts![index].products.length,
                                    (productIndex) {
                              quantityController[listCarts![productIndex].ownerId]?[productIndex] = TextEditingController(text: "0");
                              return Container(
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
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.white),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //Product Image
                                    Container(
                                      height: 100,
                                      width: 90,
                                      //padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        //color: AppColors.darkgreen,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          File(listProducts![productIndex].image),
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            //Title
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  listProducts![productIndex]
                                                      .name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                                            //Description
                                            Text(
                                              listProducts![productIndex]
                                                  .description,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              "${listProducts![productIndex].price.toStringAsFixed(2)}\$",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "${((listProducts![productIndex].price) * (moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              spacing: 8,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  onTap: () => onRemoveProduct(index),
                                                  child: const Icon(
                                                    Icons.remove_circle,
                                                    color: AppColors.darkgreen,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                  child: TextFormField(
                                                    keyboardType:TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      /* hintText: "Add quantity",
                                                            hintStyle: const TextStyle(
                                                              fontSize: 12,
                                                            ), */
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
                                                          color:
                                                              AppColors.green,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      disabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    
                                                    onFieldSubmitted: (value) {
                                                      if (value != "0.0" && value != "") {
                                                        onSetQuantityProduct(listCarts![productIndex].products[productIndex].id, double.parse(value));
                                                      }
                                                          },
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                        onAddProduct(listCarts![productIndex].products[productIndex].id);
                                                  },
                                                  child: const Icon(
                                                    Icons.add_circle,
                                                    color: AppColors.darkgreen,
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
                              );
                            }),
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
} */
