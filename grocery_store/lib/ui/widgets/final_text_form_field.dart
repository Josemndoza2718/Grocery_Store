import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/resource/colors.dart';

class FinalTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final InputDecoration? decoration;
  
  // Action button properties (from CustomTextFormField)
  final bool isButtonActive;
  final IconData buttonIcon;
  final Function()? onButtonTap;

  const FinalTextFormField({
    super.key,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.decoration,
    this.isButtonActive = false,
    this.buttonIcon = Icons.send_rounded,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    // Standard decoration based on GeneralTextformfield styling
    final defaultDecoration = InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: Theme.of(context).textTheme.bodyLarge,
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      filled: true,
      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
    );

    return Row(
      children: [
        Flexible(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            onChanged: onChanged,
            validator: validator,
            decoration: decoration ?? defaultDecoration,
          ),
        ),
        if (isButtonActive) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onButtonTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primary,
              ),
              width: 50,
              height: 50,
              child: Icon(
                buttonIcon,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
