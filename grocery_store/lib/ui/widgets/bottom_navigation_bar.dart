import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/widgets/animated_button.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.setSelectedIndex,
    required this.getProducts,
    required this.getCategories,
    required this.getCarProducts,
  });

  final int selectedIndex;
  final Function(int) setSelectedIndex;
  final Function() getProducts;
  final Function() getCategories;
  final Function() getCarProducts;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AnimatedButton(
              icon: Icons.home,
              label: "Home",
              isSelected: selectedIndex == 0,
              selectColor: AppColors.white,
              unSelectColor: AppColors.darkgreen,
              selectTextColor: AppColors.darkgreen,
              onTap: () {
                setSelectedIndex(0);
                getProducts;
                getCategories;
              },
            ),
            AnimatedButton(
              icon: Icons.person,
              label: "Profile",
              isSelected: selectedIndex == 1,
              selectColor: AppColors.white,
              unSelectColor: AppColors.darkgreen,
              selectTextColor: AppColors.darkgreen,
              onTap: () {
                setSelectedIndex(1);
                getCarProducts;
              },
            ),
            AnimatedButton(
              icon: Icons.card_giftcard,
              label: "Gifts",
              isSelected: selectedIndex == 2,
              selectColor: AppColors.white,
              unSelectColor: AppColors.darkgreen,
              selectTextColor: AppColors.darkgreen,
              onTap: () {
                setSelectedIndex(2);
              },
            ),
            AnimatedButton(
              icon: Icons.car_repair,
              label: "Car",
              isSelected: selectedIndex == 3,
              selectColor: AppColors.white,
              unSelectColor: AppColors.darkgreen,
              selectTextColor: AppColors.darkgreen,
              onTap: () {
                setSelectedIndex(3);
              },
            ),
          ],
        ));
  }
}
