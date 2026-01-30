import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/extension.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/ui/views/check/check_page.dart';
import 'package:grocery_store/ui/views/history/sales_history_page.dart';
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

  static final List<String> _pageNames = [
    "${"lbl_welcome".translate}, ${Prefs.getString(PrefKeys.userName)}",
    "", //"lbl_cart".translate,
    "lbl_check".translate,
    "lbl_settings".translate,
  ];

  List<Widget> _pageIcons(BuildContext context) {
    return [
      Container(),
      Container(),
      IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SalesHistoryPage()),
          );
        },
        icon: const Icon(Icons.history, color: AppColors.white),
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.settings, color: AppColors.white),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainPageViewModel>(builder: (context, provider, _) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        //backgroundColor: AppColors.white,
        appBar: AppBar(
          //backgroundColor: AppColors.green,
          centerTitle: false,
          toolbarHeight: 70,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          title: Text(_pageNames[provider.selectedIndex],
              style: Theme.of(context).textTheme.displaySmall),
          actions: [_pageIcons(context)[provider.selectedIndex]],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              IndexedStack(
                index: provider.selectedIndex,
                children: _pages,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomNavigationBarWidget(
                  selectedIndex: provider.selectedIndex,
                  setSelectedIndex: (index) =>
                      provider.setSelectedIndex = index,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
