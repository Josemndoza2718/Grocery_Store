// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/cash/widget/check_widget.dart';
import 'package:grocery_store/ui/view_model/check_view_model.dart';
import 'package:grocery_store/ui/view_model/car_view_model.dart';
import 'package:provider/provider.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  TextEditingController clientController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<CheckViewModel>(builder: (context, viewModel, _) {
        return Column(
          spacing: 16,
          children: [
            const SizedBox(height: 10),
            CheckWidget(
              listProducts: context.read<CarViewModel>().listProducts,
              subToTal: 0,
              moneyConversion: context.read<CarViewModel>().moneyConversion,
            ),
            if (context.read<CarViewModel>().listProducts.isNotEmpty)
              const Text(
                "Metodos de Pago",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            // Métodos de pago
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      //margin: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.only(bottom: 5, right: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.ultralightgrey),
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        //padding: const EdgeInsets.all(8),
                        //margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: AppColors.darkgreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Row(
                            spacing: 4,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card,
                                color: AppColors.white,
                              ),
                              Text(
                                "Tarjeta",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      //margin: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.only(bottom: 5, right: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.ultralightgrey),
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        //padding: const EdgeInsets.all(8),
                        //margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: AppColors.darkgreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Row(
                            spacing: 4,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: AppColors.white,
                              ),
                              Text(
                                "Efectivo",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        );
      }),
    );
  }
}
