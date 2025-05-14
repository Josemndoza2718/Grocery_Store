// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/ui/shop/widgets/shop_list_widget.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class ShopePage extends StatefulWidget {
  const ShopePage({super.key});

  @override
  State<ShopePage> createState() => _ShopePageState();
}

class _ShopePageState extends State<ShopePage> {
  int selectedIndex = 0;

  TextEditingController searchController = TextEditingController();
  TextEditingController moneyconversionController = TextEditingController();
  double money = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initMoney();
    });

  }

  void initMoney() async {
    var viewModel = context.read<HomeViewModel>();
    viewModel.moneyConversion = await Prefs.getMoneyConversion();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            spacing: 16,
            children: [
              const SizedBox(height: 10),
             const Icon(Icons.shopping_cart),
              const SizedBox(height: 10),
              //GridViewButtons
              ShopListWidget(
                  listProducts: viewModel.listProductsByCar,
                  moneyConversion: viewModel.moneyConversion,
                  onDeleteProduct: (index) => viewModel.deletedCarProduct(viewModel.listProductsByCar[index].id),
                ),
                const SizedBox(height: 100),
            ],
          );
        }
      ),
    );
  }
}



