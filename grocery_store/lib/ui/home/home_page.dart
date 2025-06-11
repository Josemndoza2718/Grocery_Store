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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              spacing: 16,
              children: [
                const SizedBox(height: 8),
                //Money Conversion
                Column(
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
                //const SizedBox(height: 10),
                //Client Menu
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        viewModel.toggleIsActive();
                      },
                      child: Container(
                        height: 55,
                        //width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.darkgreen,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(
                          Icons.person_add_alt_1_sharp,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        //margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownMenu<int>(
                          width: double.infinity,
                          enableSearch: true,
                          enableFilter: true,
                          requestFocusOnTap: true,
                          hintText: 'Select client',
                          textStyle: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          inputDecorationTheme: const InputDecorationTheme(
                            border: InputBorder.none,
                          ),
                          menuStyle: MenuStyle(
                            backgroundColor:
                                WidgetStateProperty.all(AppColors.white),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          dropdownMenuEntries:
                              viewModel.listClients.map((client) {
                            return DropdownMenuEntry<int>(
                              value: client.id,
                              label: client.name,
                              style: MenuItemButton.styleFrom(
                                foregroundColor: AppColors.black,
                              ),
                              trailingIcon: IconButton(
                                  onPressed: () {
                                    viewModel.deletedClient(client.id);
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: AppColors.red,
                                  )),
                            );
                          }).toList(),
                          onSelected: (value) {
                            final selectedClient =
                                viewModel.listClients.firstWhere(
                              (element) => element.id == value,
                            );
                            viewModel.clientId = value!;
                            viewModel.setClientName = selectedClient.name;
                                                    },
                        ),
                      ),
                    ),
                  ],
                ),
                if (viewModel.isActive)
                  CustomTextFormField(
                    isButtonActive: true,
                    controller: clientController,
                    decoration: InputDecoration(
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
                      if (clientController.text.isNotEmpty &&
                          clientController.text != "") {
                        bool exists = viewModel.listClients.any(
                            (element) => element.name == clientController.text);

                        if (!exists) {
                          viewModel
                              .createClient(name: clientController.text)
                              .then((_) {
                            viewModel.getClients();
                            clientController.clear();
                          });
                          viewModel.toggleIsActive();
                          showFloatingMessage(
                              context: context,
                              message: "User added",
                              color: AppColors.green);
                        } else {
                          showFloatingMessage(
                              context: context,
                              message: "Username already exists",
                              color: AppColors.red);
                        }
                      }
                    },
                  ),

                //GridViewButtons
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.lightwhite,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        //Text("Client ${viewModel.clientName}"),
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
                          onDeleteCategory: (index) => viewModel.deleteCategory(
                              viewModel.listCategories[index].id),
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

                            var homeViewModel = context.read<HomeViewModel>();

                            if (homeViewModel.clientName.isEmpty) {
                              showFloatingMessage(
                                  context: context,
                                  message: "¡¡¡Warning!!!. Please select a client",
                                  color: AppColors.red);
                              return;
                            }

                            if (homeViewModel.listProducts.isEmpty) {
                              showFloatingMessage(
                                  context: context,
                                  message: "No products to add to cart",
                                  color: AppColors.red);
                              return;
                            }

                            // Check if a cart for the client already exists
                            final existingCart = viewModel.listCarts.where(
                                (element) => element.ownerId == homeViewModel.clientId,
                            ).toList();

                            if (existingCart.isEmpty) {
                              viewModel.createCart(
                                ownerId: homeViewModel.clientId,
                                ownerCarName: homeViewModel.clientName,
                                products: homeViewModel.listProducts[index],
                              );
                              showFloatingMessage(
                                  context: context,
                                  message: "Product added to cart",
                                  color: AppColors.green);
                            } else {
                              viewModel.updateCart(
                                cartId: existingCart.first.id,
                                ownerId: homeViewModel.clientId,
                                ownerCarName: homeViewModel.clientName,
                                products: homeViewModel.listProducts,
                              );
                              showFloatingMessage(
                                  context: context,
                                  message:
                                      "Product added to ${homeViewModel.clientName}'s cart ",
                                  color: AppColors.green);
                            }
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
            ),
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
