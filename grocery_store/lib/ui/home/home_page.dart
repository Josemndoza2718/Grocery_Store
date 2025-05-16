// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/home/widgets/categories_widget.dart';
import 'package:grocery_store/ui/home/widgets/products_list_widget.dart';
import 'package:grocery_store/ui/view_model/add_product_view_model.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:grocery_store/ui/view_model/shop_view_model.dart';
import 'package:intl/intl.dart';
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

  double parseFormattedCurrency(String text) {
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    return double.parse(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Esto quita el foco de cualquier TextField
      },
      behavior: HitTestBehavior.opaque,
      child: SafeArea(
        child: Consumer<HomeViewModel>(builder: (context, viewModel, _) {
          return Column(
            spacing: 16,
            children: [
              const SizedBox(height: 8),
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
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              DecimalInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              hintText: "Money Conversion",
                              filled: true,
                              fillColor: AppColors.lightwhite,
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.green,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10),
                              ),
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
                            double value = parseFormattedCurrency(
                                moneyconversionController.value.text);

                            viewModel.setMoneyConversion(value);

                            Prefs.setMoneyConversion(value);

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
                              color: AppColors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              //GridViewButtons
              CategoriesWidget(
                pressedIndex: viewModel.pressedIndex,
                selectedIndexGrid: viewModel.selectedIndexGrid,
                listCategories: viewModel.listCategories,
                selectColor: AppColors.green,
                unSelectColor: AppColors.lightgrey,
                onTap: (index) {
                  viewModel.setPressedIndex(index);
                  viewModel.setSelectedCategory(
                      viewModel.listCategories[index].name);
                  viewModel.setIsFilterList(true);
                  viewModel.getProductsByCategory(
                      viewModel.listCategories[index].id);
                },
                onPressed: (index) {
                  viewModel.setPressedIndex(index);
                  viewModel.getProducts();
                  viewModel.setIsFilterList(false);
                },
                onTapUp: viewModel.setSelectedIndexGrid,
                onClose: () => viewModel.getCategories(),
                onDeleteCategory: (index) => viewModel
                    .deleteCategory(viewModel.listCategories[index].id),
              ),
              ProductsListWidget(
                listProducts: viewModel.listProducts,
                listProductsByCategory: viewModel.listProductsByCategory,
                onTap: (index) {
                  var addProductViewModel = context.read<AddProductViewModel>();

                   addProductViewModel.getCategoryId(viewModel.listProducts, index);
                },
                onPressed: (index) {
                  var viewModel = context.read<ShopViewModel>();
                  viewModel.addProductByCar(viewModel.listProducts[index]);
                  viewModel.getCarProducts();
                },
                onClose: () => viewModel.getProducts(),
                moneyConversion: viewModel.moneyConversion,
                category: viewModel.selectedCategory,
                isFilterList: viewModel.isFilterList,
                onDeleteProduct: (index) =>
                    viewModel.deleteProduct(viewModel.listProducts[index].id),
              ),
              SizedBox(height: 80),
            ],
          );
        }),
      ),
    );
  }
}

class DecimalInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,##0.00", "es_ES");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Quitar caracteres no numéricos excepto la coma
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Convertir a número con 2 decimales (suponemos que los últimos dos dígitos son decimales)
    double value = double.parse(newText) / 100;

    final formattedText = _formatter.format(value);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
