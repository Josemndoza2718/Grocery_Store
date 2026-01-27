// ignore_for_file: must_be_immutable

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/extension.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';
import 'package:grocery_store/ui/views/cash/widget/check_widget.dart';
import 'package:grocery_store/ui/widgets/FloatingMessage.dart';
import 'package:grocery_store/ui/widgets/general_textformfield.dart';
import 'package:grocery_store/ui/view_model/old/cart_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:grocery_store/ui/views/history/sales_history_page.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  TextEditingController clientController = TextEditingController();
  TextEditingController discountController = TextEditingController(text: "0");
  TextEditingController deliveryController = TextEditingController(text: "0");
  ScreenshotController screenshotController = ScreenshotController();

  /* Future<dynamic> ShowCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Center(child: Image.memory(capturedImage)),
      ),
    );
  } */

  Future<void> saveAndShareImage(Uint8List image) async {
    final time = DateTime.now().toIso8601String().replaceAll(".", "_");
    final directory = await getExternalStorageDirectory();
    final imagePath = File('${directory?.path}/$time.png');

    await imagePath.writeAsBytes(image);
    await Share.shareXFiles([XFile(imagePath.path)]);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().setListPayProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("lbl_check".translate),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: "Historial de Ventas",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SalesHistoryPage()),
                );
              },
            ),
          ],
        ),
        body: Consumer<CartViewModel>(builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              spacing: 16,
              children: [
                const SizedBox(height: 10),
                /* Consumer<CartViewModel>(builder: (context, viewModel, _) {
              return Container(
                //height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightwhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Flexible(
                  child: Column(spacing: 8, children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Deudores",
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    viewModel.filterlistCarts.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.lightgrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "No debts",
                              style: TextStyle(
                                  color: AppColors.lightwhite,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : Container(
                            height: 250,
                            child: GridView.builder(
                              scrollDirection: Axis.vertical,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 2.3,
                              ),
                              itemCount: viewModel.filterlistCarts.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailPayPage(
                                            payPart: viewModel
                                                .filterlistCarts[0].payPart,
                                          ),
                                        ));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
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
                                          height: 100,
                                          width: 90,
                                          //padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            //color: AppColors.darkgreen,
                                          ),
                                          /* child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                                "https://www.iconpacks.net/icons/2/free-user-icon-3297-thumb.png"),
                                            /* Image.file(
                                                          File(product.image),
                                                          height: double.infinity,
                                                          width: double.infinity,
                                                          fit: BoxFit.cover,
                                                        ), */
                                          ), */
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
                                                    const Text(
                                                      "Nombre",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: const Icon(
                                                        Icons.delete_forever,
                                                        color: AppColors.red,
                                                        //size: 30,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                //Description
                                                const Text(
                                                  "product.description",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                const Text(
                                                  "price", //"${product.price.toStringAsFixed(2)}\$",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const Text(
                                                  "Total price", //"${((product.price) * (widget.moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ]),
                ),
              );
            }),
             */
                /* Consumer<CartViewModel>(builder: (context, viewModel, _) {
              return Container(
                //height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightwhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Flexible(
                  child: Column(
                    spacing: 8,
                    children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Pago",
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    viewModel.paymentlistCarts.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.lightgrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "No debts",
                              style: TextStyle(
                                  color: AppColors.lightwhite,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : Container(
                            height: 250,
                            child: GridView.builder(
                              scrollDirection: Axis.vertical,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 2.3,
                              ),
                              itemCount: viewModel.paymentlistCarts.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailPayPage(
                                            payPart: viewModel
                                                .filterlistCarts[0].payPart,
                                          ),
                                        ));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.symmetric(vertical: 4),
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
                                              File(viewModel
                                                  .paymentlistCarts[index]
                                                  .products[index]
                                                  .image),
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
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                //Title
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Nombre",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: const Icon(
                                                        Icons.delete_forever,
                                                        color: AppColors.red,
                                                        //size: 30,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                //Description
                                                const Text(
                                                  "product.description",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                const Text(
                                                  "price", //"${product.price.toStringAsFixed(2)}\$",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const Text(
                                                  "Total price", //"${((product.price) * (widget.moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ]),
                ),
              );
            }),
 */
                //Discount and delivery
                Row(
                  spacing: 8,
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GeneralTextformfield(
                        controller: discountController,
                        labelText: "lbl_discount".translate,
                        hintText: "lbl_discount".translate,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) {
                          context
                              .read<CartViewModel>()
                              .setDiscount(double.tryParse(value) ?? 0);
                        },
                      ),
                    ),
                    Expanded(
                      child: GeneralTextformfield(
                        controller: deliveryController,
                        labelText: "lbl_delivery".translate,
                        hintText: "lbl_delivery".translate,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'))
                        ],
                        onChanged: (value) {
                          context
                              .read<CartViewModel>()
                              .setDelivery(double.tryParse(value) ?? 0);
                        },
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Screenshot(
                    controller: screenshotController,
                    child: CheckWidget(
                      cart: provider.selectedCartForCheckout,
                      subToTal: provider.subTotal,
                      moneyConversion: provider.moneyConversion,
                      iva: double.parse(Prefs.getString(PrefKeys.iva) ?? "0"),
                      discount: provider.discount,
                      delivery: provider.delivery,
                      onTap: () {
                        discountController.text = "0";
                        deliveryController.text = "0";
                        provider.clearData();
                      },
                    ),
                  ),
                ),
                /* if (provider.selectedCartForCheckout != null &&
                provider.selectedCartForCheckout!.products.isNotEmpty)
              const Text(
                "Metodos de Pago",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            // Métodos de pago
            if (provider.selectedCartForCheckout != null &&
                provider.selectedCartForCheckout!.products.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      //margin: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.only(bottom: 5, right: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.ultralightgrey),
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        //padding: const EdgeInsets.all(8),
                        //margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: AppColors.darkgreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Row(
                            spacing: 4,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card,
                                color: AppColors.white,
                              ),
                              Text(
                                "Tarjeta",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      //margin: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.only(bottom: 5, right: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.ultralightgrey),
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        //padding: const EdgeInsets.all(8),
                        //margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: AppColors.darkgreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Row(
                            spacing: 4,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: AppColors.white,
                              ),
                              Text(
                                "Efectivo",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    screenshotController.capture().then((image) async {
                      if (image != null) {
                        final directory = await getApplicationDocumentsDirectory();
                        final imagePath = await File('${directory.path}/image.png').create();
                        await imagePath.writeAsBytes(image);
                        saveAndShareImage(image);
                      }
                    }).catchError((onError) {
                      print(onError);
                    });
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.only(bottom: 5, right: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.ultralightgrey),
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.share, color: AppColors.white, size: 32),
                      ),
                    ),
                  ),
                ),
              ],
            ), */
                GestureDetector(
                  onTap: () {
                    if (provider.selectedCartForCheckout != null) {
                      screenshotController.capture().then((image) async {
                        if (image != null) {
                          final directory =
                              await getApplicationDocumentsDirectory();
                          final imagePath =
                              await File('${directory.path}/image.png')
                                  .create();
                          await imagePath.writeAsBytes(image);
                          saveAndShareImage(image);
                          // Save to history
                          if (provider.selectedCartForCheckout != null) {
                            provider
                                .markCartAsPaid(
                                    provider.selectedCartForCheckout!.id)
                                .then((value) {
                              discountController.text = "0";
                              deliveryController.text = "0";
                              provider.clearData();
                            });
                          }
                        }
                      }).catchError((onError) {
                        print(onError);
                      });
                    } else {
                      showFloatingMessage(
                          context: context,
                          message: "lbl_warning_no_items".translate,
                          color: AppColors.red);
                    }
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.only(bottom: 5, right: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.ultralightgrey),
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Row(
                          spacing: 16,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.print, color: AppColors.white, size: 32),
                            Text(
                              "Imprimir",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        }));
  }
}
