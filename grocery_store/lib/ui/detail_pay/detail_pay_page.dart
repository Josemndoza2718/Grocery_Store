// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/detail_pay/widgets/products_list_widget.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:grocery_store/ui/widgets/general_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailPayPage extends StatefulWidget {
  final int payPart;
  const DetailPayPage({super.key, required this.payPart});

  @override
  State<DetailPayPage> createState() => DetailPayPageState();
}

class DetailPayPageState extends State<DetailPayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        //toolbarHeight: 40,
      ),
      body: Consumer<HomeViewModel>(builder: (context, viewModel, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              children: [
                //Client Data
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
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
                          child: Image.network(
                              "https://www.iconpacks.net/icons/2/free-user-icon-3297-thumb.png"),
                          /* Image.file(
                                        File(product.image),
                                        height: double.infinity,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ), */
                        ),
                      ),
                      //Product Data
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Title
                            Text(
                              "Abelardo Mendoza",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //Description
                            Text(
                              "Productos: 30",
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              "Precio cuota: 20\$", //"${product.price.toStringAsFixed(2)}\$",
                              style: TextStyle(
                                fontSize: 14,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Total price: 400\$", //"${((product.price) * (widget.moneyConversion ?? 0)).toStringAsFixed(2)}bs",
                              style: TextStyle(
                                fontSize: 14,
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                /* Container(
                  height: 250,
                  child: ProductsListWidget(
                      page: Container(),
                      isPayMode: true,
                      listProducts: viewModel.listProducts,
                      listProductsByCategory: [],
                      onTap: (index) {},
                      onPressed: (index) {},
                      onClose: () => {},
                      moneyConversion: 0,
                      category: "",
                      isFilterList: false,
                      onDeleteProduct: (index) => {}),
                ), */
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                        color: AppColors.lightwhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                      itemCount: viewModel.listProducts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.18,
                      ),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              height: 90,
                              width: 90,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(viewModel.listProducts[index].image),
                                  // height: 80,
                                  // width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text("X ${viewModel.listProducts[index].quantity}",
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontSize: 14,
                                )),
                          ],
                        );
                      }),
                ),
                PaymentInPartsWidget(
                  itemCount: widget.payPart,
                  price: 400,
                ),
                const SizedBox(height: 8),
                GeneralButton(
                  child: Center(
                    child: Text(
                      "📷 Añadir Comprobante",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  /* onTap: () async {
                          final pickedImageGalery = await PhoneImage()
                              .pickImageFromGallery(ImageSource.gallery);

                          if (pickedImageGalery != null) {
                            viewModel.setGalleryImage(pickedImageGalery);
                          }
                        }, */
                ),
                //Comprobantes de pago
                SizedBox(
                  height: 250,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1.18,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 60,
                        width: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            "https://mundo-oriental.com/upload/3229.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }
}
