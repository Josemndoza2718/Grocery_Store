import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/extension.dart';
import 'package:grocery_store/ui/view/home/widgets/decimal_widget.dart';
import 'package:grocery_store/ui/view/widgets/custom_textformfield.dart';

class AsignPriceWidget extends StatelessWidget {
  final String label;
  final double price;
  final TextEditingController controller;
  final Function() onTap;
  const AsignPriceWidget(
      {super.key,
      required this.label,
      required this.price,
      required this.controller,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${price.toStringAsFixed(2)}"),
        CustomTextFormField(
          isButtonActive: true,
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            DecimalInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: "lbl_money_conversion".translate,
            filled: true,
            fillColor: AppColors.lightwhite,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.green,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onTap: () => onTap(),
          /* double value = parseFormattedCurrency(controller.value.text);

            viewModel.setMoneyConversion(value);

            Prefs.setMoneyConversion(value);

            controller.clear(); */
        ),
      ],
    );
  }
}
