import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/home/home_page.dart';
import 'package:grocery_store/ui/shop/shope_page.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:grocery_store/ui/view_model/main_page_view_model.dart';
import 'package:grocery_store/ui/view_model/shop_view_model.dart';
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
    const ShopePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
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
                    getCarProducts: () => context.read<ShopViewModel>().getCarProducts(),
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


