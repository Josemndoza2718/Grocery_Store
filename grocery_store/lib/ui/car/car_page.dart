// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/car/widgets/shop_list_widget.dart';
import 'package:grocery_store/ui/view_model/car_view_model.dart';
import 'package:grocery_store/ui/widgets/FloatingMessage.dart';
import 'package:provider/provider.dart';

class CarPage extends StatefulWidget {
  const CarPage({super.key});

  @override
  State<CarPage> createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<CarViewModel>(builder: (context, viewModel, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            spacing: 16,
            children: [
              const SizedBox(height: 10),
              //GridViewButtons
              // ignore: unnecessary_null_comparison
              if (viewModel.listCarts != null && viewModel.listCarts.isNotEmpty)
                ShopListWidget(
                  listCarts: viewModel.listCarts,
                  listProducts: viewModel.listProducts,
                  isActivePanel: viewModel.isActivePanel,
                  moneyConversion: viewModel.moneyConversion,
                  onTapPanel: (index) => viewModel.isActiveListPanel(index),
                  onRemoveCart: (index) => viewModel.deletedCart(index),
                  onSetTap: (index, value) => viewModel.setQuantityProductForm(index, double.parse("$value")),
                  onAddProduct: (value) => viewModel.addQuantityProduct(value),
                  onRemoveProduct: (value) => viewModel.removeQuantityProduct(value),
                  onSetQuantityProduct: (id, value) => viewModel.onSetQuantityProduct(id, value),
                  onChanged: (value, productId) => viewModel.updateQuantityManually(value, productId),
                  onDeleteProduct: (index) {
                    viewModel.deletedProduct(viewModel.listProducts[index].id);
                    showFloatingMessage(
                        context: context,
                        message: "Product deleted to cart",
                        color: AppColors.red);
                  },
                ),
              //Button
              /* if (viewModel.listProducts.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    /* var shopViewModel = context.read<CarViewModel>();
                    String defaulClientName = shopViewModel.getRandomString(8);
                    
                    var viewModel = context.read<CheckViewModel>();
          
                    shopViewModel.getCarProducts();
          
                    viewModel.addCheckProduct(
                      status: "bought",
                      ownerCarName: defaulClientName,
                    ); */
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
                ), */
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }
}
