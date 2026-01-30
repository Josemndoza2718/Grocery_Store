import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/extension.dart';
import 'package:grocery_store/ui/widgets/animated_button.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) setSelectedIndex;
  const BottomNavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.setSelectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AnimatedButton(
              icon: Icons.home,
              label: "lbl_home".translate,
              isSelected: selectedIndex == 0,
              selectColor: AppColors.white,
              unSelectColor: AppColors.darkgreen,
              selectTextColor: AppColors.darkgreen,
              height: 40,
              onTap: () {
                setSelectedIndex(0);
              },
            ),
            AnimatedButton(
              icon: Icons.shopping_cart,
              label: "lbl_cart".translate,
              isSelected: selectedIndex == 1,
              selectColor: AppColors.white,
              unSelectColor: AppColors.darkgreen,
              selectTextColor: AppColors.darkgreen,
              height: 40,
              onTap: () {
                setSelectedIndex(1);
              },
            ),
            AnimatedButton(
              icon: Icons.attach_money,
              label: "lbl_sales".translate,
              isSelected: selectedIndex == 2,
              selectColor: AppColors.white,
              unSelectColor: AppColors.darkgreen,
              selectTextColor: AppColors.darkgreen,
              height: 40,
              onTap: () {
                setSelectedIndex(2);
              },
            ),
            AnimatedButton(
              icon: Icons.settings,
              label: "lbl_settings".translate,
              isSelected: selectedIndex == 3,
              selectColor: AppColors.white,
              unSelectColor: AppColors.darkgreen,
              selectTextColor: AppColors.darkgreen,
              height: 40,
              onTap: () {
                setSelectedIndex(3);
              },
            ),
          ],
        ));
  }
}
