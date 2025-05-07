import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/domain/entities/category.dart';
import 'package:grocery_store/ui/add_category_page.dart';

class CategoriesWidget extends StatefulWidget {
   CategoriesWidget({
    super.key,
    this.name,
    required this.pressedIndex,
    required this.selectedIndexGrid,
    required this.listCategories,
    required this.onClose,
    required this.onTap,
    required this.onTapUp,
    required this.onDeleteCategory,
    required this.onPressed,
    this.selectColor = Colors.blue,
    this.unSelectColor = Colors.grey,
  });

  final int? pressedIndex;
  final int? selectedIndexGrid;
  final List<Category>? listCategories;
  final String? name;
  final Color? selectColor;
  final Color? unSelectColor;
  final Function() onClose;
  final Function(int) onTap;
  final Function(int) onPressed;
  final Function(int) onTapUp;
  final Function(int) onDeleteCategory;

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  Color? dominantColor;

  Brightness? brightness;

  bool isDark = false;

  Future<Color> _generateColorScheme(String path) async {
    final imageProvider = FileImage(File(path));

    final colorScheme = await ColorScheme.fromImageProvider(
      provider: imageProvider,
      brightness: Brightness.light,
    );

    return dominantColor = colorScheme.primary;
  }

  Future<Brightness> _getOpacityColor(String path) async {
    final imageProvider = FileImage(File(path));

    final colorScheme = await ColorScheme.fromImageProvider(
      provider: imageProvider,
      brightness: Brightness.light,
    );

    final Color primary = colorScheme.primary;

    return brightness = ThemeData.estimateBrightnessForColor(primary);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Text(
              "Categories",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Container(
            color: Colors.transparent,
            height: 130,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.18,
              ),
              itemCount: (widget.listCategories?.length ?? 0) + 1 + (widget.listCategories!.length > 1 ? 1 : 0),
              itemBuilder: (context, index) {
                int adjustedIndex = index - (widget.listCategories!.length > 1 ? 1 : 0);
                if (widget.listCategories!.length > 1 && index == 0) {
                  return GestureDetector(
                    onTap: () => widget.onPressed(adjustedIndex),
                    onTapUp: (_) => widget.onTapUp(adjustedIndex),
                    child: AnimatedScale(
                      scale: widget.pressedIndex == adjustedIndex
                          ? 0.9
                          : 1.0, // Escala animada
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: widget.selectedIndexGrid == adjustedIndex
                              ? widget.selectColor //Colors.green.shade200
                              : widget.unSelectColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.category, size: 40),
                            ),
                            Text(
                              "All Items",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Recalcular el índice real de la categoría

                if (adjustedIndex == widget.listCategories?.length) {
                  return Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddCategoryPage(),
                              ),
                            ).then((_) {
                              widget.onClose();
                            });
                          },
                          icon: const Icon(Icons.add_circle, size: 40),
                        ),
                        const Text(
                          "Add Item",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () {
                    _generateColorScheme(widget.listCategories![adjustedIndex].image);
                    _getOpacityColor(widget.listCategories![adjustedIndex ].image);
                    widget.onTap(adjustedIndex);
                  },
                  onTapUp: (_) => widget.onTapUp(adjustedIndex),
                  onDoubleTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCategoryPage(
                          category: widget.listCategories![adjustedIndex],
                        ),
                      ),
                    ).then((_) {
                      widget.onClose();
                    });
                  },
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Category'),
                          content: const Text(
                              'Are you sure you want to delete this category?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                widget.onDeleteCategory(adjustedIndex);

                                /* viewModel
                                    .deleteCategory(listCategories![index].id); */
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: AnimatedScale(
                    scale: widget.pressedIndex == adjustedIndex
                        ? 0.9
                        : 1.0, // Escala animada
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.selectedIndexGrid == adjustedIndex
                            ? dominantColor
                            : widget.unSelectColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundImage: FileImage(
                                  File(widget.listCategories![adjustedIndex].image)),
                              backgroundColor: Colors.white,
                              radius: 30,
                            ),
                          ),
                          Text(widget.listCategories![adjustedIndex].name,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                //color: Colors.white,
                              )), // Nombre de la categoría
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
