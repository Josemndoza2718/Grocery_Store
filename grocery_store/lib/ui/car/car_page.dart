// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/car/widgets/shop_list_widget.dart';
import 'package:grocery_store/ui/view_model/check_view_model.dart';
import 'package:grocery_store/ui/view_model/shop_view_model.dart';
import 'package:grocery_store/ui/widgets/custom_textformfield.dart';
import 'package:provider/provider.dart';

class ShopePage extends StatefulWidget {
  const ShopePage({super.key});

  @override
  State<ShopePage> createState() => _ShopePageState();
}

class _ShopePageState extends State<ShopePage> {
  TextEditingController clientController = TextEditingController();
  

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
                      value: null,
                      dropdownColor: AppColors.green,
                      iconEnabledColor: AppColors.white,
                      decoration: const InputDecoration(
                        hintText: 'Select client',
                        hintStyle: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: AppColors.green,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                      items: viewModel.listClients.map((client) {
                        return DropdownMenuItem(
                          value: client.id,
                          child: Text(
                            client.name,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {},
                    ),
                  ),
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      viewModel.toggleIsActive();
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
            if (viewModel.isActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: CustomTextFormField(
                  isButtonActive: true,
                  controller: clientController,
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.person,
                      color: AppColors.green,
                    ),
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
                  onTap: () {
                    //viewModel.deletedClient(viewModel.listClients[0].id);
                    viewModel
                        .createClient(name: clientController.text)
                        .then((_) {
                      viewModel.getClients();
                      clientController.clear();
                    });
                    viewModel.toggleIsActive();
                  },
                ),
              ),
            //GridViewButtons
            ShopListWidget(
              listProducts: viewModel.listProducts,
              isActiveList: viewModel.isActiveList,
              moneyConversion: viewModel.moneyConversion,
              onTap: (index) => viewModel.isActiveListProduct(index),
              onSetTap: (index, value) => viewModel.setQuantityProductForm(index, double.parse("$value")),
              onAddProduct: (value) => viewModel.addQuantityProduct(value),
              onRemoveProduct: (index) => viewModel.removeQuantityProduct(index),
              onDeleteProduct: (index) => viewModel.deletedCarProduct(viewModel.listProducts[index].id),
            ),
            //Button
            if (viewModel.listProducts.isNotEmpty)
              GestureDetector(
                onTap: () {
                  var shopViewModel = context.read<ShopViewModel>();
                  String defaulClientName = shopViewModel.getRandomString(8);
                  
                  var viewModel = context.read<CheckViewModel>();

                  shopViewModel.getCarProducts();

                  viewModel.addCheckProduct(
                    status: "bought",
                    ownerCarName: defaulClientName,
                  );
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
                    alignment: Alignment.center,
                    child: Text(
                      "Buy",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        );
      }),
    );
  }
}
