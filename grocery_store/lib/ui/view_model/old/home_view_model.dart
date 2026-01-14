import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/category.dart';
import 'package:grocery_store/core/domain/entities/client.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/get_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/delete_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/get_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/update_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/send_product_firebase_use_cases.dart';

class HomeViewModel extends ChangeNotifier {
  //Products
  final NewGetProductsUseCases getProductsUseCases;
  final SendProductFirebaseUseCases sendProductsToFirebaseUseCases;
  final CreateProductsUseCases createProductsUseCases;
  final NewDeleteProductsUseCases deleteProductsUseCases;
  final UpdateProductsUseCases updateProductsUseCases;

  //Clients
  final CreateClientUseCases createClientUseCases;
  final GetClientsUseCases getClientsUseCases;
  final DeleteClientsUseCases deleteClientsUseCases;

  HomeViewModel({
    //Products
    required this.getProductsUseCases,
    required this.sendProductsToFirebaseUseCases,
    required this.createProductsUseCases,
    required this.deleteProductsUseCases,
    required this.updateProductsUseCases,
    //Clients
    required this.createClientUseCases,
    required this.getClientsUseCases,
    required this.deleteClientsUseCases,
  }) {
    getProducts();
    getClients();
  }

  List<Category> listCategories = [];
  List<Product> listProducts = [];
  List<Product> listFilterProducts = [];
  List<Product> listProductsByCategory = [];

  List<Client> listClients = [];
  bool _isActive = false;

  String clientName = "";
  int clientId = 0;

  int _selectedIndexGrid = -1;
  int _pressedIndex = -1;
  double _moneyConversion = 0;

  String _selectedCategory = '';

  bool _isFilterList = false;

  double get moneyConversion => _moneyConversion;
  int get pressedIndex => _pressedIndex;
  int get selectedIndexGrid => _selectedIndexGrid;
  String get selectedCategory => _selectedCategory;
  bool get isFilterList => _isFilterList;
  bool get isActive => _isActive;

  //Create Client
  Future<void> createClient({
    required String name,
  }) async {
    if (name.isNotEmpty && name != "") {
      bool exists = listClients.any((element) => element.name == name);
      if (!exists) {
        Random random = Random();
        int randomNumber = random.nextInt(100000000);
        await createClientUseCases.call(
          Client(
            id: randomNumber,
            name: name,
          ),
        );
        await getClients();
      } else {
        print("ya existe");
      }
    }
  }

  Future<void> saveDataToFirebase() async {
    await sendProductsToFirebaseUseCases.call();
    notifyListeners();
  }

  Future<void> getClients() async {
    listClients = await getClientsUseCases.call();
    notifyListeners();
  }

  Future<void> deletedClient(int id) async {
    await deleteClientsUseCases.deleteClient(id);
    getClients();
  }

  set setClientName(String value) {
    clientName = value;
    notifyListeners();
  }

  set setClientId(int value) {
    clientId = value;
    notifyListeners();
  }

/*   String getRandomString(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  } */

  void toggleIsActive() {
    _isActive = !_isActive;
    notifyListeners();
  }

  set moneyConversion(double value) {
    _moneyConversion = value;
    notifyListeners();
  }

  void initList() {
    listFilterProducts.clear();
    listFilterProducts.addAll(listProducts);
    notifyListeners();
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      listFilterProducts = listProducts;
    } else {
      listFilterProducts = listProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void setIsFilterList(bool value) {
    _isFilterList = value;
    notifyListeners();
  }

  void setMoneyConversion(double value) {
    _moneyConversion = value;
    notifyListeners();
  }

  void setPressedIndex(int index) {
    _pressedIndex = index;
    notifyListeners();
  }

  void setSelectedIndexGrid(int index) {
    _selectedIndexGrid = index;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  //Products
  Future<void> getProducts() async {
    getProductsUseCases.callStream().listen((products) {
      listProducts = products;
      // Re-apply filter if needed
      if (_isFilterList && listFilterProducts.length != listProducts.length) {
        // Optionally maintain filter state here, but for now just init list
        // or re-run filter if query is stored.
        // Simpler approach: update filter list if it's currently showing all (initList logic)
        // or if we decide to just reset filter on update.
        // Let's just update lists and notify.
        initList();
      } else {
        initList();
      }
    });
  }

  Future<void> getProductsByCategory(int category) async {
    listProductsByCategory.clear();
    for (var element in listProducts) {
      if (!listProductsByCategory.contains(element)) {
        listProductsByCategory.add(element);
      }
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await deleteProductsUseCases.deleteProduct(id);
    // getProducts() is stream-based now, so it updates automatically
  }

  Future<void> updateProduct(Product product) async {
    await updateProductsUseCases.call(product);
    // getProducts() is stream-based now, so it updates automatically
  }
}
