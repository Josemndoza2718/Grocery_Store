// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:grocery_store/core/data/repositories/local/new/new_product_repository_impl.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/view/add_product/add_product_page.dart';
import 'package:grocery_store/ui/view/home/widgets/asig_price_widget.dart';
import 'package:grocery_store/ui/view/home/widgets/products_list_widget.dart';
import 'package:grocery_store/ui/view_model/old/home_view_model.dart';
import 'package:grocery_store/ui/view_model/old/cart_view_model.dart';
import 'package:grocery_store/ui/view/widgets/FloatingMessage.dart';
import 'package:grocery_store/ui/view/widgets/custom_textformfield.dart';
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

  double parseFormattedCurrency(String text) {
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    return double.parse(cleaned);
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
            stream: NewProductRepositoryImpl().getAllProductsStream(),
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
                        onTap: () {
                          double value = parseFormattedCurrency(
                              moneyconversionController.value.text);

                          provider.setMoneyConversion(value);
                          Prefs.setMoneyConversion(value);
                          moneyconversionController.clear();
                        },
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
                                  return DropdownMenuEntry<int>(
                                    value: client.id,
                                    label: client.name,
                                    style: MenuItemButton.styleFrom(
                                      foregroundColor: AppColors.black,
                                    ),
                                    trailingIcon: IconButton(
                                        onPressed: () {
                                          provider.deletedClient(client.id);
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: AppColors.red,
                                        )),
                                  );
                                }).toList(),
                                onSelected: (value) {
                                  final selectedClient =
                                      provider.listClients.firstWhere(
                                    (element) => element.id == value,
                                  );
                                  provider.clientId = value!;
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
                          onTap: () {
                            if (clientController.text.isNotEmpty &&
                                clientController.text != "") {
                              bool exists = provider.listClients.any(
                                  (element) =>
                                      element.name == clientController.text);

                              if (!exists) {
                                provider
                                    .createClient(name: clientController.text)
                                    .then((_) {
                                  provider.getClients();
                                  clientController.clear();
                                });
                                provider.toggleIsActive();
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
                                onTap: (index) {}, //TODO: VER SI SE DEJA
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
