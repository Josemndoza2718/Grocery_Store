// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/view/cart/widgets/shop_list_widget.dart';
import 'package:grocery_store/ui/view_model/old/cart_view_model.dart';
import 'package:grocery_store/ui/view/widgets/FloatingMessage.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<CartViewModel>(builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            spacing: 16,
            children: [
              const SizedBox(height: 10),
              //GridViewButtons
              // ignore: unnecessary_null_comparison
              if (provider.listCarts != null && provider.listCarts.isNotEmpty)
                ShopListWidget(
                  listCarts: provider.listCarts.reversed.toList(),
                  listProducts: provider.listProducts,
                  isActivePanel: provider.isActivePanel,
                  moneyConversion: provider.moneyConversion,
                  onTapPanel: (index) => provider.isActiveListPanel(index),
                  onRemoveCart: (index) => provider.deletedCart(index),
                  //onSetTap: (index, value) => viewModel.setQuantityProductForm(index, double.parse("$value")),
                  onAddProduct: (value) => provider.addQuantityProduct(value),
                  onRemoveProduct: (value) =>provider.removeQuantityProduct(value),
                  onSetQuantityProduct: (id, value) =>provider.onSetQuantityProduct(id, value),
                  onChanged: (value, productId) =>provider.updateQuantityManually(value, productId),
                  onDeleteProduct: (cartId, productId) {
                    provider.updateProductCart(cartId, productId.toString());
                    showFloatingMessage(
                        context: context,
                        message: "Product deleted to cart",
                        color: AppColors.red);
                  },
                  onSetPayProduct: (p0, p1) => provider.onSetPayProduct(p0, p1),
                  onPaymentCart: (cartId) {
                    // Preparar los productos del carrito para checkout
                    provider.prepareCartForCheckout(cartId);
                    provider.getSubTotal();
                    
      
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }
}
