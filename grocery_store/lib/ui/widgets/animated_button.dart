import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color selectColor;
  final Color unSelectColor;
  final Color? selectTextColor;
  final Color? unSelectTextolor;
  final double height;

  const AnimatedButton({
    Key? key,
    required this.icon,
    this.label,
    this.onTap,
    this.selectColor = Colors.blue,
    this.unSelectColor = Colors.grey,
    this.selectTextColor = Colors.white,
    this.unSelectTextolor = Colors.white,
    this.height = 60,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: height,
        width: isSelected && label != null ? 100 : height,
        decoration: BoxDecoration(
          color: isSelected ? selectColor : unSelectColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: isSelected && label != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(icon, color: isSelected ? selectTextColor : unSelectTextolor,),
                  Text(label!, style: Theme.of(context).textTheme.titleSmall),
                ],
              )
            : Icon(icon, color: Colors.white),
      ),
    );
  }
}
