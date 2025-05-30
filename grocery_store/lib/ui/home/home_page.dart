// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/add_product/add_product_page.dart';
import 'package:grocery_store/ui/home/widgets/categories_widget.dart';
import 'package:grocery_store/ui/home/widgets/products_list_widget.dart';
import 'package:grocery_store/ui/view_model/add_product_view_model.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:grocery_store/ui/view_model/car_view_model.dart';
import 'package:grocery_store/ui/widgets/FloatingMessage.dart';
import 'package:grocery_store/ui/widgets/custom_textformfield.dart';
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
  TextEditingController clientController = TextEditingController();
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
      onTap: () => FocusScope.of(context)
          .unfocus(), // Esto quita el foco de cualquier TextField
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
                    CustomTextFormField(
                      isButtonActive: true,
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
                      onTap: () {
                        double value = parseFormattedCurrency(
                            moneyconversionController.value.text);

                        viewModel.setMoneyConversion(value);

                        Prefs.setMoneyConversion(value);

                        moneyconversionController.clear();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButtonFormField(
                        value: null,
                        dropdownColor: AppColors.green,
                        iconEnabledColor: AppColors.white,
                        decoration: const InputDecoration(
                          hintText: 'Select client',
                          hintStyle: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: AppColors.green,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                        items: viewModel.listClients.map((client) {
                          return DropdownMenuItem(
                            value: client.id,
                            child: Text(
                              client.name,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        viewModel.toggleIsActive();
                      },
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "New client",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (viewModel.isActive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: CustomTextFormField(
                    isButtonActive: true,
                    controller: clientController,
                    decoration: InputDecoration(
                      icon: const Icon(
                        Icons.person,
                        color: AppColors.green,
                      ),
                      hintText: "Name or Id",
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
                    onTap: () {
                      //viewModel.deletedClient(viewModel.listClients[0].id);
                      viewModel
                          .createClient(name: clientController.text)
                          .then((_) {
                        viewModel.getClients();
                        clientController.clear();
                      });
                      viewModel.toggleIsActive();
                    },
                  ),
                ),
              /* Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Car to: ",
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ), */
              //GridViewButtons

              Flexible(
                child: Container(
                  //padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: AppColors.lightwhite,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
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
                        page: const AddProductPage(),
                        listProducts: viewModel.listProducts,
                        listProductsByCategory:
                            viewModel.listProductsByCategory,
                        onTap: (index) {
                          var addProductViewModel =
                              context.read<AddProductViewModel>();
                          addProductViewModel.getCategoryId(
                              viewModel.listProducts, index);
                        },
                        onPressed: (index) {
                          var viewModel = context.read<CarViewModel>();
                          viewModel.addProductByCar(context
                              .read<HomeViewModel>()
                              .listProducts[index]);
                          viewModel.getCarProducts();
                          showFloatingMessage(
                              context: context,
                              message: "Product added to cart",
                              color: AppColors.green);
                        },
                        onClose: () => viewModel.getProducts(),
                        moneyConversion: viewModel.moneyConversion,
                        category: viewModel.selectedCategory,
                        isFilterList: viewModel.isFilterList,
                        onDeleteProduct: (index) => viewModel
                            .deleteProduct(viewModel.listProducts[index].id),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
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
