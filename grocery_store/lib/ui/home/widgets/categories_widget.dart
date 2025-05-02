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
  });

  final int? pressedIndex;
  final int? selectedIndexGrid;
  final List<Category>? listCategories;
  final String? name;
  final Function() onClose;
  final Function(int) onTap;
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
              itemCount: listCategories!.length + 1,
              itemBuilder: (context, index) {
                if (index == listCategories?.length) {
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
                  onTap: () {
                    //pressedIndex = index; // Marca el botón como presionado
                    onTap(index);
                  },
                  onTapUp: (_) {
                    //pressedIndex = null; // Quita el efecto al soltar
                    //selectedIndexGrid = index;
                    onTapUp(index);
                  },
                  onDoubleTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCategoryPage(
                          category: listCategories![index],
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
                                onDeleteCategory(index);

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
                    scale: pressedIndex == index ? 0.9 : 1.0, // Escala animada
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selectedIndexGrid == index
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
                              backgroundImage:
                                  FileImage(File(listCategories![index].image)),
                              backgroundColor: Colors.white,
                              radius: 30,
                            ),
                          ),
                          Text(listCategories![index].name,
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
