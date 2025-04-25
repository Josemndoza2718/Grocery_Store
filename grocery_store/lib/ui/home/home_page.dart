// ignore_for_file: must_be_immutable

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/domain/entities/category.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/ui/add_category_page.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  void initState() {
    context.read<HomeViewModel>().initProductsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        spacing: 10,
        children: [
          const SizedBox(height: 10),
          //Bar-search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SearchAnchor(
              viewShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              isFullScreen: false,
              builder: (context, controller) {
                return SearchBar(
                  controller: controller,
                  leading: const Icon(Icons.search),
                  hintText: "Search",
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                  /* constraints: BoxConstraints(
                      minHeight: 60,
                      maxWidth: 330,
                    ), */
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                );
              },
              suggestionsBuilder: (context, controller) {
                return List<ListTile>.generate(5, (int index) {
                  final String item = 'item $index';
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      setState(() {
                        controller.closeView(item);
                      });
                    },
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          //GridViewButtons
          Consumer<HomeViewModel>(builder: (context, viewModel, _) {
            return CategoriesWidget(
              pressedIndex: viewModel.pressedIndex,
              selectedIndexGrid: viewModel.selectedIndexGrid,
              listCategories: viewModel.listCategories,
              onTap: viewModel.setPressedIndex,
              onTapUp: viewModel.setSelectedIndexGrid,
              onClose: () => viewModel.getCategories(),
              onDeleteCategory: (index) =>
                  viewModel.deleteCategory(viewModel.listCategories[index].id),
            );
          }),
          Consumer<HomeViewModel>(builder: (context, addProductViewModel, _) {
            return ItemListWidget(
              listProducts: (addProductViewModel.listProducts..sort((a, b) => 
                  a.name.compareTo(b.name))),
            );
          }),
        ],
      ),
    );
  }
}

class ItemListWidget extends StatelessWidget {
  const ItemListWidget({
    super.key,
    required this.listProducts, 
  });

  final List<Product>? listProducts;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      //padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color.fromARGB(59, 184, 184, 184),
          borderRadius: BorderRadius.circular(10)),
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          //mainAxisSpacing: 2,
          //childAspectRatio: 1.18,
        ),
        itemCount: listProducts?.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            /* onTap: () {
              setState(() {
                pressedIndex = index; // Marca el botón como presionado
              });
            },
            onTapUp: (_) {
              setState(() {
                pressedIndex = null; // Quita el efecto al soltar
                selectedIndexGrid = index; // Selecciona el botón
              });
            }, */
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    115, 184, 184, 184), // Color para el no seleccionado
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.file(File(listProducts![index].image), 
                        height: 80,
                        width: 80,
                        //fit: BoxFit.cover,
                        ),
                  ),
                  Text(
                    listProducts![index].name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    listProducts![index].description,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    listProducts![index].stockQuantity.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        listProducts![index].price.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoriesWidget extends StatelessWidget {
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
  });

  int? pressedIndex;
  int? selectedIndexGrid;
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
                                builder: (context) => AddCategoryPage(),
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
