// ignore_for_file: must_be_immutable


import 'package:flutter/material.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/resource/colors.dart';
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
  TextEditingController moneyconversionController = TextEditingController();
  double money = 0;

  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initMoney();
    });
  }

  void initMoney() async {
    var viewModel = context.read<HomeViewModel>();
    viewModel.moneyConversion = await Prefs.getMoneyConversion();
  }



  @override
  Widget build(BuildContext context) {
     

    return SafeArea(
      child: Consumer<HomeViewModel>(builder: (context, viewModel, _) {
        return Column(
          spacing: 10,
          children: [
            const SizedBox(height: 10),
            //Bar-search
            /* Padding(
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
              const SizedBox(height: 10), */

            //Money Conversion
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tasa en uso: ${viewModel.moneyConversion}"),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: moneyconversionController,
                          decoration: InputDecoration(
                            hintText: "Money Conversion",
                            filled: true,
                            fillColor: AppColors.lightwhite,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          viewModel.setMoneyConversion(double.tryParse(
                                  moneyconversionController.value.text) ??
                              0);
                          Prefs.setMoneyConversion(
                              double.parse(moneyconversionController.text));
                          moneyconversionController.clear();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.green,
                          ),
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.send_rounded,
                            color: AppColors.darkgreen,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            //GridViewButtons
            CategoriesWidget(
              pressedIndex: viewModel.pressedIndex,
              selectedIndexGrid: viewModel.selectedIndexGrid,
              listCategories: viewModel.listCategories,
              selectColor: AppColors.green,
              unSelectColor: AppColors.lightgrey,
              onTap: (index) {
                viewModel.setPressedIndex(index);
                viewModel.setSelectedCategory(viewModel.listCategories[index].name);
                viewModel.setIsFilterList(true);
                viewModel.getProductsByCategory(viewModel.listCategories[index].name);
              },
              onPressed: (index) {
                viewModel.setPressedIndex(index);
                viewModel.getProducts();
                viewModel.setIsFilterList(false);
              },
              onTapUp: viewModel.setSelectedIndexGrid,
              onClose: () => viewModel.getCategories(),
              onDeleteCategory: (index) => viewModel.deleteCategory(viewModel.listCategories[index].id),
             
            ),
            ProductsListWidget(
              listProducts: viewModel.listProducts,
              listProductsByCategory: viewModel.listProductsByCategory,
              onClose: () => viewModel.getProducts(),
              moneyConversion: viewModel.moneyConversion,
              category: viewModel.selectedCategory,
              isFilterList: viewModel.isFilterList,
              onDeleteProduct: (index) =>
                  viewModel.deleteProduct(viewModel.listProducts[index].id),
            ),
            const SizedBox(height: 100),
          ],
        );
      }),
    );
  }
}
