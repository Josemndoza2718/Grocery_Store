// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:grocery_store/data/repositories/local/new/new_product_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/views/add_product/add_product_page.dart';
import 'package:grocery_store/ui/views/home/widgets/asig_price_widget.dart';
import 'package:grocery_store/ui/views/home/widgets/products_list_widget.dart';
import 'package:grocery_store/ui/view_model/providers/home_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/cart_view_model.dart';
import 'package:grocery_store/ui/widgets/FloatingMessage.dart';
import 'package:grocery_store/ui/widgets/custom_textformfield.dart';
import 'package:provider/provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int selectedIndex = 0;

  TextEditingController searchController = TextEditingController();
  TextEditingController moneyconversionController = TextEditingController();
  TextEditingController clientController = TextEditingController();
  double money = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initMoney();
      var provider = Provider.of<HomeViewModel>(context, listen: false);
      await provider.getProducts();
      provider.initList();
    });
  }

  void initMoney() async {
    var viewModel = context.read<HomeViewModel>();
    viewModel.moneyConversion = await Prefs.getMoneyConversion();
  }

  /// Parses a value formatted as "1.234,56". Returns `null` when the text is
  /// empty or invalid, instead of throwing a FormatException.
  double? parseFormattedCurrency(String text) {
    final cleaned = text.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  /// Validates and saves the conversion rate. Returns false (and warns the
  /// user) when the value is empty, invalid or not greater than 0.
  bool _saveMoneyConversion(HomeViewModel provider) {
    final value = parseFormattedCurrency(moneyconversionController.text);
    if (value == null || value <= 0) {
      showFloatingMessage(
          context: context,
          message: 'Ingrese una tasa de cambio válida mayor a 0',
          color: AppColors.red);
      return false;
    }
    provider.setMoneyConversion(value);
    Prefs.setMoneyConversion(value);
    moneyconversionController.clear();
    FocusScope.of(context).unfocus();
    return true;
  }

  Future<void> onAddItemProduct(HomeViewModel viewModel, int index) async {
    var carViewModel = Provider.of<CartViewModel>(context, listen: false);

    if (viewModel.clientName.isEmpty) {
      showFloatingMessage(
          context: context,
          message: "¡¡¡Adventencia!!!. Por favor seleccione un cliente",
          //"¡¡¡Warning!!!. Please select a client",
          color: AppColors.red);
      return;
    }

    if (viewModel.listProducts.isEmpty) {
      showFloatingMessage(
          context: context,
          message: "No products to add to cart",
          color: AppColors.red);
      return;
    }
    // Check if a cart for the client already exists
    final existingCart = carViewModel.listCarts
        .where(
          (element) => element.ownerId == viewModel.clientId,
        )
        .toList();

    if (existingCart.isEmpty) {
      await carViewModel.createCart(
        ownerId: viewModel.clientId,
        ownerCarName: viewModel.clientName,
        products: viewModel.listProducts[index],
      );
      showFloatingMessage(
          context: context,
          message: "Product added to cart",
          color: AppColors.darkgreen);
    } else {
      await carViewModel.updateCart(
        cartId: existingCart.first.id,
        ownerId: viewModel.clientId,
        ownerCarName: viewModel.clientName,
        products: viewModel.listProducts[index],
      );

      showFloatingMessage(
          context: context,
          message: "Product added to ${viewModel.clientName}'s cart ",
          color: AppColors.darkgreen);
    }
    context.read<HomeViewModel>().getProducts();
    context.read<CartViewModel>().getAllCarts();
    context.read<CartViewModel>().getMoneyConversion();
  }

  /// Creates the client typed in [clientController] in Firestore.
  Future<void> _onCreateClient(HomeViewModel provider) async {
    final name = clientController.text.trim();
    if (name.isEmpty) return;

    if (provider.clientExists(name)) {
      showFloatingMessage(
          context: context,
          message: "Username already exists",
          color: AppColors.red);
      return;
    }

    clientController.clear();
    provider.toggleIsActive();
    final failure = await provider.createClient(name: name);
    if (!mounted) return;
    showFloatingMessage(
        context: context,
        message: failure?.message ?? "User added",
        color: failure == null ? AppColors.darkgreen : AppColors.red);
  }

  @override
  Widget build(BuildContext context) {
    //final uid = FirebaseAuth.instance.currentUser!.uid;
    //final provider = Provider.of<AddProductViewModel>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context)
          .unfocus(), // Esto quita el foco de cualquier TextField
      behavior: HitTestBehavior.opaque,
      child: SafeArea(
        child: StreamBuilder<List<Product>>(
            stream: NewProductRepositoryImpl().getAllProductsStream(
                userId: context.read<HomeViewModel>().userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = snapshot.data;
              if (products == null) {
                // Esto puede indicar que el usuario de Auth existe, pero no en Firestore (un error de registro)
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 80,
                            color: AppColors.green,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddProductPage(),
                              ),
                            );
                          },
                        ),
                        const Text(
                          textAlign: TextAlign.center,
                          "No user data found.\nTap the icon to create user data.",
                          style:
                              TextStyle(fontSize: 16, color: AppColors.black),
                        )
                      ],
                    ),
                  ),
                );
              }
              return Consumer<HomeViewModel>(builder: (context, provider, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    spacing: 16,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "Welcome, user",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      //Money Conversion
                      AsignPriceWidget(
                        //TODO: CAMBIAR EL TEXTO POR UN LABEL
                        label: 'Tasa en Uso',
                        price: provider.moneyConversion,
                        controller: moneyconversionController,
                        onTap: () => _saveMoneyConversion(provider),
                      ),
                      //Client Menu
                      Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              provider.toggleIsActive();
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
                              child: DropdownMenu<String>(
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
                                inputDecorationTheme:
                                    const InputDecorationTheme(
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
                                    provider.listClients.map((client) {
                                  return DropdownMenuEntry<String>(
                                    value: client.id,
                                    label: client.name,
                                    style: MenuItemButton.styleFrom(
                                      foregroundColor: AppColors.black,
                                    ),
                                    trailingIcon: IconButton(
                                        onPressed: () async {
                                          final failure = await provider
                                              .deletedClient(client.id);
                                          if (failure != null &&
                                              context.mounted) {
                                            showFloatingMessage(
                                                context: context,
                                                message: failure.message,
                                                color: AppColors.red);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: AppColors.red,
                                        )),
                                  );
                                }).toList(),
                                onSelected: (value) {
                                  if (value == null) return;
                                  final selectedClient =
                                      provider.listClients.firstWhere(
                                    (element) => element.id == value,
                                  );
                                  provider.clientId = value;
                                  provider.setClientName = selectedClient.name;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (provider.isActive)
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
                          onTap: () => _onCreateClient(provider),
                        ),
                      //GridViewButtons
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.lightwhite,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              //Search Bar & AddProduct
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Container(
                                      height: 50,
                                      margin: const EdgeInsets.all(8),
                                      child: SearchBar(
                                        backgroundColor:
                                            const WidgetStatePropertyAll(
                                                AppColors.white),
                                        controller: searchController,
                                        leading: const Icon(Icons.search),
                                        shape: const WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        )),
                                        onChanged: (value) {
                                          provider.filterProducts(value);
                                        },
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.green,
                                        ),
                                        width: 50,
                                        height: 50,
                                        child: const Icon(
                                          Icons.add_circle,
                                          color: AppColors.white,
                                        )),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AddProductPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              //Text("Client ${viewModel.clientName}"),
                              ProductsListWidget(
                                listProducts: products,
                                onPressed: (index) async =>
                                    await onAddItemProduct(provider, index),
                                onClose: () => provider.getProducts(),
                                moneyConversion: provider.moneyConversion,
                                onDeleteProduct: (index) =>
                                    provider.deleteProduct(
                                        provider.listProducts[index].id),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              });
            }),
      ),
    );
  }
}
