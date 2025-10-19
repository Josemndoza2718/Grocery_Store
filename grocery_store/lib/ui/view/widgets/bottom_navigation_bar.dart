import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/view_model/old/cart_view_model.dart';
import 'package:grocery_store/ui/view/widgets/animated_button.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) setSelectedIndex;
  final Function()? getProducts;
  final Function()? getCarProducts;
  final Function()? getMoneyConversion;
  const BottomNavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.setSelectedIndex,
    this.getProducts,
    this.getCarProducts,
    this.getMoneyConversion,
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
              label: "Home",
              isSelected: selectedIndex == 0,
              selectColor: AppColors.white,
              unSelectColor: AppColors.darkgreen,
              selectTextColor: AppColors.darkgreen,
              height: 40,
              onTap: () {
                setSelectedIndex(0);
                getProducts!();
              },
            ),
            AnimatedButton(
              icon: Icons.shopping_cart,
              label: "Car",
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
              label: "Sales",
              isSelected: selectedIndex == 2,
              selectColor: AppColors.white,
              unSelectColor: AppColors.darkgreen,
              selectTextColor: AppColors.darkgreen,
              height: 40,
              onTap: () {
                setSelectedIndex(2);
                context.read<CartViewModel>().setListPayProduct();
              },
            ),
            AnimatedButton(
              icon: Icons.car_repair,
              label: "Car",
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
