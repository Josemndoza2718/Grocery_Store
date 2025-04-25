import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final bool isSelected;

  const AnimatedButton({
    Key? key,
    required this.icon,
    this.label,
    this.onTap,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 60,
        width: isSelected && label != null ? 100 : 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueGrey.shade700 : Colors.blueGrey,
          borderRadius: BorderRadius.circular(40),
        ),
        child: isSelected && label != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(icon, color: Colors.white),
                  Text(label!, style: const TextStyle(color: Colors.white)),
                ],
              )
            : Icon(icon, color: Colors.white),
      ),
    );
  }
}