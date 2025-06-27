// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/home/widgets/products_list_widget.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:grocery_store/ui/widgets/general_button.dart';
import 'package:grocery_store/ui/widgets/general_list_widget.dart';
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
                GeneralListWidget(
                  itemCount: 8,
                  crossAxisCount: 2,
                  color: AppColors.lightwhite,
                  onTap: (index) {
                    viewModel.setPressedIndex(index);
                    viewModel.setSelectedCategory(viewModel.listCategories[index].name);
                    viewModel.setIsFilterList(true);
                    viewModel.getProductsByCategory(viewModel.listCategories[index].id);
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                                File(viewModel.listProducts[0].image),
                                // height: 80,
                                // width: 80,
                                fit: BoxFit.cover,
                              ),
                        ),
                      ),
                      Text("X ${viewModel.listProducts[0].quantity}",
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 14,
                          )),
                    ],
                  ),
                ),
                PaymentInstallmentsWidget(itemCount: widget.payPart, price: 400,),
                const SizedBox(height: 8),
                const GeneralButton(
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
                ),
                GeneralListWidget(
                  itemCount: 8,
                  color: AppColors.transparent,
                  onTap: (index) {
                    viewModel.setPressedIndex(index);
                    viewModel.setSelectedCategory(
                        viewModel.listCategories[index].name);
                    viewModel.setIsFilterList(true);
                    viewModel.getProductsByCategory(
                        viewModel.listCategories[index].id);
                  },
                  child: GestureDetector(
                    child: Container(
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
                    ),
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

class PaymentInstallmentsWidget extends StatelessWidget {

  final int itemCount;
  final double price;
  PaymentInstallmentsWidget({
    super.key, required this.itemCount, required this.price,
  });

  int n = 1;
  DateTime hoy = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: 250, //530,
        width: double.infinity,
        color: AppColors.transparent,
        child: ListView.separated(
          //physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  color: AppColors.transparent,
                  child: Column(
                    spacing: 4,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 8,
                        width: 2,
                        color: AppColors.darkgreen,
                      ),
                      Container(
                        height: 8,
                        width: 2,
                        color: AppColors.darkgreen,
                      ),
                      Container(
                        height: 8,
                        width: 2,
                        color: AppColors.darkgreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          itemBuilder: (context, index) => Container(
            color: AppColors.transparent,
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.darkgreen,
                  ),
                  child: Center(
                    child: Text( 
                      "${n++}",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(hoy.add(Duration(days: 15 * index))),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text("${price/itemCount}\$",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 14,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
