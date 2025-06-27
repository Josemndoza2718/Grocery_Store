import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/cash/check_page.dart';
import 'package:grocery_store/ui/home/home_page.dart';
import 'package:grocery_store/ui/cart/cart_page.dart';
import 'package:grocery_store/ui/last_page/last.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:grocery_store/ui/view_model/main_page_view_model.dart';
import 'package:grocery_store/ui/view_model/cart_view_model.dart';
import 'package:grocery_store/ui/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
    required this.selectedIndex,
  });

  final int selectedIndex;

  static final List<Widget> _pages = [
    const HomePage(),
    const CartPage(),
    const CheckPage(),
    const LastPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: const Text("Grocery Store", style: TextStyle(fontSize: 20, color: AppColors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<MainPageViewModel>(
          builder: (context, viewModel, _) {
            return Stack(
              children: [
                IndexedStack(
                  index: viewModel.selectedIndex,
                  children: _pages,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomNavigationBarWidget(
                    selectedIndex: viewModel.selectedIndex,
                    setSelectedIndex: (index) {
                      viewModel.setSelectedIndex = index;
                    },
                    getProducts: () => context.read<HomeViewModel>().getProducts(),
                    getCategories: () => context.read<HomeViewModel>().getCategories(),
                    getCarProducts: () => context.read<CartViewModel>().getAllCarts(),
                    getMoneyConversion: () => context.read<CartViewModel>().getMoneyConversion(),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}


