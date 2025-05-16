// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/shop/widgets/shop_list_widget.dart';
import 'package:grocery_store/ui/view_model/shop_view_model.dart';
import 'package:provider/provider.dart';

class ShopePage extends StatefulWidget {
  const ShopePage({super.key});

  @override
  State<ShopePage> createState() => _ShopePageState();
}

class _ShopePageState extends State<ShopePage> {
  

  bool isActive = false;
  
  
  
  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
      child: Consumer<ShopViewModel>(builder: (context, viewModel, _) {
        return Column(
          spacing: 16,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonFormField(
                      value: "General",
                      dropdownColor:AppColors.green,
                      iconEnabledColor: AppColors.white,
                      decoration: const InputDecoration(
                        hintText: 'Select client',
                        filled: true,
                        fillColor: AppColors.green,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: "General",
                          child: Text("General",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        ), 
                        DropdownMenuItem<String>(
                          value: "Client 1",
                          child: Text("Client 1",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        DropdownMenuItem<String>(
                          value: "Client 2",
                          child: Text("Client 2",
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isActive = true;
                      });
                    },
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "New client",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //const SizedBox(height: 10),
            if (isActive)
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Name or Id",
                          filled: true,
                          fillColor: AppColors.lightwhite,
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
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isActive = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.green,
                        ),
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.save,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            //GridViewButtons
            ShopListWidget(
              listProducts: viewModel.listProducts,
              moneyConversion: viewModel.moneyConversion,
              onDeleteProduct: (index) => viewModel
                  .deletedCarProduct(viewModel.listProducts[index].id),
            ),
            const SizedBox(height: 80),
          ],
        );
      }),
    );
  }
}
