import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/extension.dart';
import 'package:grocery_store/ui/views/cash/check_page.dart';
import 'package:grocery_store/ui/views/home/home_page.dart';
import 'package:grocery_store/ui/views/cart/cart_page.dart';
import 'package:grocery_store/ui/views/settings/settings_page.dart';
import 'package:grocery_store/ui/view_model/providers/main_page_view_model.dart';
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
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        centerTitle: true,
        title: Text("lbl_app_name".translate,
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.white,
            )),
        actions: const [
          /* IconButton(
              onPressed: () {
                var viewModel =
                    Provider.of<HomeViewModel>(context, listen: false);
                viewModel.saveDataToFirebase();
              },
              icon: const Icon(
                Icons.save,
                color: AppColors.white,
              )),
          IconButton(
              onPressed: () async {
                var viewModel =
                    Provider.of<HomeViewModel>(context, listen: false);
                await viewModel.getProducts();
                viewModel.initList();
              },
              icon: const Icon(
                Icons.restart_alt_rounded,
                color: AppColors.white,
              )), */
        ],
      ),
      body: SafeArea(
        child: Consumer<MainPageViewModel>(builder: (context, viewModel, _) {
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
                  setSelectedIndex: (index) => viewModel.setSelectedIndex = index,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
