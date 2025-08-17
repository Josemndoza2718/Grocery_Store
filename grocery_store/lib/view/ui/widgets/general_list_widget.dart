

import 'package:flutter/material.dart';


class GeneralListWidget extends StatefulWidget {
  const GeneralListWidget({
    super.key,
    this.height = 250,
    this.width = double.infinity,
    this.label,
    this.childAspectRatio = 1.18,
    required this.itemCount,
    required this.itemBuilder,
    this.scrollDirection = Axis.horizontal,
    required this.child,
    this.onTap,
    this.crossAxisCount = 1,
    this.color = Colors.blue,
  });

  final double height;
  final double width;
  final String? label;
  final int itemCount;
  final double childAspectRatio;
  final int crossAxisCount; // Default value, can be changed if needed
  final Axis scrollDirection;
  final Widget child;
  final Function(int)? onTap;
  final Color color;
  final Function(BuildContext, int) itemBuilder;

  @override
  State<GeneralListWidget> createState() => _GeneralListWidgetState();
}

class _GeneralListWidgetState extends State<GeneralListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        scrollDirection: widget.scrollDirection,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          childAspectRatio: widget.childAspectRatio,
        ),
        itemCount: widget.itemCount,
        itemBuilder: 
        (context, index) {
          return widget.child;
        
          /* if (hasAllItemsButton && index == 0) {
            return GestureDetector(
              onTap: () => widget.onPressed(realIndex),
              onTapUp: (_) => widget.onTapUp(realIndex),
              child: Container(),
            );
          } else if (realIndex == widget.listCategories!.length) {
            return Container();
          } else {
            return widget.child;
          } */
        },
      ),
    );
  }
}
