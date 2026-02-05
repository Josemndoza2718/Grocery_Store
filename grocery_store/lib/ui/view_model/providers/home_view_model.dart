import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/category.dart';
import 'package:grocery_store/domain/entities/client.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/get_clients_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/delete_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/get_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/update_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/send_product_firebase_use_cases.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';

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
  String _searchQuery = '';

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
      //TODO: generar id unico
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
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      listFilterProducts = List.from(listProducts);
    } else {
      final lowercaseQuery = _searchQuery.toLowerCase();
      listFilterProducts = listProducts.where((product) {
        final matchesName = product.name.toLowerCase().contains(lowercaseQuery);
        final matchesCode = product.idStock.toLowerCase().contains(lowercaseQuery);
        return matchesName || matchesCode;
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    initList();
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
    final userId = Prefs.getString(PrefKeys.userId) ?? '';

    getProductsUseCases.callStream(userId: userId).listen((products) {
      listProducts = products;
      // Re-apply current filter instead of just resetting to full list
      filterProducts(_searchQuery);
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
    final result = await deleteProductsUseCases.deleteProduct(id);
    result.fold(
      onSuccess: (_) {}, 
      onError: (failure) => print('Error deleting product: ${failure.message}'),
    );
  }

  Future<void> updateProduct(Product product) async {
    final result = await updateProductsUseCases.call(product);
    result.fold(
      onSuccess: (_) {},
      onError: (failure) => print('Error updating product: ${failure.message}'),
    );
  }
}
