// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/view/ui/detail_pay/detail_pay_page.dart';
import 'package:grocery_store/view/ui/view_model/cart_view_model.dart';
import 'package:grocery_store/view/ui/view_model/check_view_model.dart';
import 'package:grocery_store/view/ui/widgets/general_list_widget.dart';
import 'package:provider/provider.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  TextEditingController clientController = TextEditingController();
  double sliderValue = 2;

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckViewModel>(builder: (context, viewModel, _) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          spacing: 16,
          children: [
            const SizedBox(height: 10),
            Consumer<CartViewModel>(builder: (context, viewModel, _) {
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
            Container(
              height: 200,
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
                      "Decontado",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 16,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    /* onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetailPayPage(payPart: 2,),
                          ));
                    }, */
                    child: Container(
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
                      child: Column(
                        children: [
                          Row(
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
                                /* child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Nombre",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
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
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const Text(
                                        "price", //"${product.price.toStringAsFixed(2)}\$",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        "Total price", //"${((product.price) * (widget.moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            /* CheckWidget(
              listProducts: context.read<CarViewModel>().listProducts,
              subToTal: 0,
              moneyConversion: context.read<CarViewModel>().moneyConversion,
            ),
            if (context.read<CarViewModel>().listProducts.isNotEmpty)
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
              ],
            ), */
            const SizedBox(height: 80),
          ],
        ),
      );
    });
  }
}
