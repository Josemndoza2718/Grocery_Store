// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/view/cart/widgets/shop_list_widget.dart';
import 'package:grocery_store/ui/view_model/old/cart_view_model.dart';
import 'package:grocery_store/ui/view/widgets/FloatingMessage.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<CartViewModel>(builder: (context, viewModel, _) {
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
                  listCarts: viewModel.listCarts.reversed.toList(),
                  listProducts: viewModel.listProducts,
                  isActivePanel: viewModel.isActivePanel,
                  moneyConversion: viewModel.moneyConversion,
                  onTapPanel: (index) => viewModel.isActiveListPanel(index),
                  onRemoveCart: (index) => viewModel.deletedCart(index),
                  //onSetTap: (index, value) => viewModel.setQuantityProductForm(index, double.parse("$value")),
                  onAddProduct: (value) => viewModel.addQuantityProduct(value),
                  onRemoveProduct: (value) =>
                      viewModel.removeQuantityProduct(value),
                  onSetQuantityProduct: (id, value) =>
                      viewModel.onSetQuantityProduct(id, value),
                  onChanged: (value, productId) =>
                      viewModel.updateQuantityManually(value, productId),
                  onDeleteProduct: (cartId, productId) {
                    viewModel.updateProductCart(cartId, productId.toString());
                    showFloatingMessage(
                        context: context,
                        message: "Product deleted to cart",
                        color: AppColors.red);
                  },
                  onSetPayProduct: (p0, p1) {
                    viewModel.onSetPayProduct(p0, p1);
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
