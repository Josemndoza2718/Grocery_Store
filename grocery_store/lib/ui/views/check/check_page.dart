// ignore_for_file: must_be_immutable

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/extension.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';
import 'package:grocery_store/ui/views/check/widget/check_widget.dart';
import 'package:grocery_store/ui/widgets/FloatingMessage.dart';
import 'package:grocery_store/ui/widgets/general_textformfield.dart';
import 'package:grocery_store/ui/view_model/providers/cart_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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
    return Consumer<CartViewModel>(builder: (context, provider, _) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          spacing: 16,
          children: [
            const SizedBox(height: 10),
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            GestureDetector(
              onTap: () {
                if (provider.selectedCartForCheckout != null) {
                  screenshotController.capture().then((image) async {
                    if (image != null) {
                      final directory =
                          await getApplicationDocumentsDirectory();
                      final imagePath =
                          await File('${directory.path}/image.png').create();
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
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.print,
                            color: AppColors.white, size: 32),
                        Text(
                          "lbl_print".translate,
                          style: Theme.of(context).textTheme.labelLarge,
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
    });
  }
}
