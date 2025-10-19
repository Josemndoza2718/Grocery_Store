import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';

class GeneralTextformfield extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? labelText;
  final String? hintText;
  //final IconData? icon;
  final String? Function(String?)? validator;
  const GeneralTextformfield(
      {super.key,
      this.controller,
      this.keyboardType,
      this.maxLines,
      this.labelText,
      this.hintText,
      //this.icon,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        //prefixIcon: Icon(icon),
        //border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        filled: true,
        fillColor: AppColors.lightwhite,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
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
      ),
      validator: validator,
    );
  }
}
