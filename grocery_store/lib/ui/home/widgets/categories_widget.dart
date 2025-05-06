import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/domain/entities/category.dart';
import 'package:grocery_store/ui/add_category_page.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({
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
  });

  final int? pressedIndex;
  final int? selectedIndexGrid;
  final List<Category>? listCategories;
  final String? name;
  final Function() onClose;
  final Function(int) onTap;
  final Function(int) onPressed;
  final Function(int) onTapUp;
  final Function(int) onDeleteCategory;

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
              itemCount: (listCategories?.length ?? 0) + 1 + (listCategories!.length > 1 ? 1 : 0),
              itemBuilder: (context, index) {
                int adjustedIndex = index - (listCategories!.length > 1 ? 1 : 0);
                if (listCategories!.length > 1 && index == 0) {
                  return GestureDetector(
                    onTap: () => onPressed(adjustedIndex),
                    onTapUp: (_) => onTapUp(adjustedIndex),
                    child: AnimatedScale(
                      scale: pressedIndex == adjustedIndex
                          ? 0.9
                          : 1.0, // Escala animada
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: selectedIndexGrid == adjustedIndex
                          ? Colors.blue //Colors.green.shade200
                          : const Color.fromARGB(115, 184, 184, 184),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category, size: 40),
                            Text(
                              "All Items",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Recalcular el índice real de la categoría
                
                if (adjustedIndex == listCategories?.length) {
                  return Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(115, 184, 184, 184),
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
                              onClose();
                            });
                          },
                          icon: const Icon(Icons.add_circle, size: 40),
                        ),
                        const Text(
                          "Add Item",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () => onTap(adjustedIndex),
                  onTapUp: (_) => onTapUp(adjustedIndex),
                  onDoubleTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCategoryPage(
                          category: listCategories![adjustedIndex],
                        ),
                      ),
                    ).then((_) {
                      onClose();
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
                                onDeleteCategory(adjustedIndex);

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
                    scale: pressedIndex == adjustedIndex
                        ? 0.9
                        : 1.0, // Escala animada
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selectedIndexGrid == adjustedIndex
                            ? Colors.blue
                            : const Color.fromARGB(115, 184, 184, 184),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundImage: FileImage(
                                  File(listCategories![adjustedIndex].image)),
                              backgroundColor: Colors.white,
                              radius: 30,
                            ),
                          ),
                          Text(listCategories![adjustedIndex].name,
                              style: const TextStyle(
                                fontSize: 12,
                              )), // Nombre de la categoría
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          /* AnimatedScale(
            scale: 1.0, // Escala animada
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    115, 184, 184, 184), // Color para el no seleccionado
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add_circle,
                          size: 40,
                        )),
                  ),
                  const Text('add category',
                      style: TextStyle(
                        fontSize: 12,
                      )),
                ],
              ),
            ),
          ), */
        ],
      ),
    );
  }
}
