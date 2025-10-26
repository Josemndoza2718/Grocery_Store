import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';

class GeneralButton extends StatefulWidget {
  const GeneralButton({
    super.key,
    this.height = 50,
    this.width = double.infinity,
    this.onTap,
    this.child,
  });

  final double height;
  final double width;
  final Function()? onTap;
  final Widget? child;

  @override
  State<GeneralButton> createState() => _GeneralButtonState();
}

class _GeneralButtonState extends State<GeneralButton> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isTapped = true;
        });
        widget.onTap?.call();
      },
      onTapUp: (_) {
        setState(() {
          isTapped = false;
        });
      },
      child: AnimatedScale(
        scale: isTapped ? 0.9 : 1.0, // Escala animada
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: AppColors.darkgreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
