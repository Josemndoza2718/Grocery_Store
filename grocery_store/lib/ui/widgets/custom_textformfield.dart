import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para DecimalInputFormatter
import 'package:grocery_store/core/resource/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? decoration;
  final bool? isButtonActive;
  final Function()? onTap;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.decoration = const InputDecoration(),
    this.isButtonActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: decoration,
          ),
        ),
        if (isButtonActive == true) const SizedBox(width: 10),
        if (isButtonActive == true)
          GestureDetector(
            onTap: () => onTap!(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.green,
              ),
              width: 50,
              height: 50,
              child: const Icon(
                Icons.send_rounded,
                color: AppColors.white,
              ),
            ),
          )
      ],
    );
  }
}
