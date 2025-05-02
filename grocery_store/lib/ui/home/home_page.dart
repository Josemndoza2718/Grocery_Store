// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:grocery_store/ui/home/widgets/categories_widget.dart';
import 'package:grocery_store/ui/home/widgets/products_list_widget.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initProductsList();
    }); */
    //context.read<HomeViewModel>().initProductsList();
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Flexible(
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Name",
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue,
                    ),
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.send_rounded), ),
                )
              ],
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
            return ProductsListWidget(
              listProducts: (addProductViewModel.listProducts
                //..sort((a, b) => a.name.compareTo(b.name))
                ),
              onClose: () => addProductViewModel.getProducts(),
            );
          }),
        ],
      ),
    );
  }
}



