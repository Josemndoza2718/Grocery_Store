import 'package:flutter/material.dart';
import 'package:grocery_store/ui/home/home_page.dart';
import 'package:grocery_store/ui/view_model/bottom_navigation_bar_view_model.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:grocery_store/widgets/animated_button.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarPages extends StatelessWidget {
  const BottomNavigationBarPages({
    super.key,
    required this.selectedIndex,
  });

  final int selectedIndex;

  static final List<Widget> _pages = [
    const HomePage(),
    //AddProductPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Consumer<BottomNavigationBarViewModel>(
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
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AnimatedButton(
                              icon: Icons.home,
                              label: "Home",
                              isSelected: viewModel.selectedIndex == 0,
                              onTap: () {
                               viewModel.setSelectedIndex = 0;
                               context.read<HomeViewModel>().getProducts();
                               context.read<HomeViewModel>().getCategories();
                              },
                            ),
                            AnimatedButton(
                              icon: Icons.person,
                              label: "Profile",
                              isSelected: viewModel.selectedIndex == 1,
                              onTap: () {
                                viewModel.setSelectedIndex = 1;
                              },
                            ),
                            AnimatedButton(
                              icon: Icons.card_giftcard,
                              label: "Gifts",
                              isSelected: viewModel.selectedIndex == 2,
                              onTap: () {
                                viewModel.setSelectedIndex = 2;
                              },
                            ),
                            AnimatedButton(
                              icon: Icons.car_repair,
                              label: "Car",
                              isSelected: viewModel.selectedIndex == 3,
                              onTap: () {
                                viewModel.setSelectedIndex = 3;
                              },
                            ),
                          ],
                        )
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
