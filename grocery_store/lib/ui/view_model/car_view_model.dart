import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/client.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/car/create_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/delete_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/get_car_products_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/car/update_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/get_clients_use_cases%20copy.dart';

class CarViewModel extends ChangeNotifier {
  CarViewModel({
    required this.getCarProductsUseCases,
    required this.addCarProductsUseCases,
    required this.deleteCarProductsUseCases,
    required this.updateCarProductsUseCases,
    required this.createClientUseCases,
    required this.getClientsUseCases,
    required this.deleteClientsUseCases,
  }) {
    getCarProducts();
    getMoneyConversion();
  }

  final GetCarProductsUseCases getCarProductsUseCases;
  final CreateCarProductsUseCases addCarProductsUseCases;
  final DeleteCarProductsUseCases deleteCarProductsUseCases;
  final UpdateCarProductsUseCases updateCarProductsUseCases;

  //Clients
  final CreateClientUseCases createClientUseCases;
  final GetClientsUseCases getClientsUseCases;
  final DeleteClientsUseCases deleteClientsUseCases;

  List<Product> listProducts = [];
  List<Cart> listCarts = [];
  List<Client> listClients = [];

  List<bool> _isActiveList = [];
  List<bool> _isActivePanel = [];

  double _moneyConversion = 0;
  double _quantityProduct = 0;
  bool _isActive = false;

  double get moneyConversion => _moneyConversion;
  double get quantityProduct => _quantityProduct;
  bool get isActive => _isActive;
  List<bool> get isActiveList => _isActiveList;
  List<bool> get isActivePanel => _isActivePanel;
  List<Product> get listProductsByCar => listProducts;

  void isActiveListProduct(int index) {
    _isActiveList[index] = !_isActiveList[index];
    notifyListeners();
  }

  void isActiveListPanel(int index) {
    _isActivePanel[index] = !_isActivePanel[index];
    notifyListeners();
  }

  void addQuantityProduct(int index) {
    if (listProducts[index].stockQuantity > 0 &&
        listProducts[index].quantity < listProducts[index].stockQuantity) {
      listProducts[index].quantity++;
    }
    notifyListeners();
  }

  void removeQuantityProduct(int index) {
    if (listProducts[index].quantity > 0) {
      listProducts[index].quantity--;
    }
    notifyListeners();
  }

  void setQuantityProductForm(int index, double value) {
    listProducts[index].quantity = value;
    notifyListeners();
  }

  set moneyConversion(double value) {
    _moneyConversion = value;
    notifyListeners();
  }

  void getMoneyConversion() async {
    double money = await Prefs.getMoneyConversion();
    _moneyConversion = money;
    notifyListeners();
  }

  //Car_Products
  Future<void> createCart({
    required int ownerId,
    required String ownerCarName,
    required List<Product> products,
  }) async {
    if (ownerId != null && products.isNotEmpty && ownerCarName.isNotEmpty) {
      Random random = Random();
      int randomNumber = random.nextInt(100000000);

      await addCarProductsUseCases.call(
        Cart(
          id: randomNumber,
          ownerId: ownerId,
          ownerCarName: ownerCarName,
          status: 'pending',
          products: products,
        ),
      );
      getCarProducts();
    }
  }

  Future<void> updateCart({
    required int cartId,
    required int ownerId,
    required String ownerCarName,
    required List<Product> products,
  }) async {
    if (cartId != null && ownerId != null && products.isNotEmpty && ownerCarName.isNotEmpty) {
      
      await updateCarProductsUseCases.updateProduct(
        Cart(
          id: cartId,
          ownerId: ownerId,
          ownerCarName: ownerCarName,
          status: 'pending',
          products: products,
        ),
      );
      getCarProducts();
    }
  }

  /* Future<void> addProductByCar(Product product) async {
    if (product.stockQuantity > 0) {
      await addCarProductsUseCases.call(product);
    }
  } */

  Future<void> getCarProducts() async {
    listCarts = await getCarProductsUseCases.call();
    _isActiveList = List.filled(listCarts.length, false);
    _isActivePanel = List.filled(listCarts.length, false);
    notifyListeners();
  }

  /*  Future<void> getListProducts() async {
    listProducts = await getCarProductsUseCases.call();
    _isActiveList = List.filled(listProducts.length, false);
    _isActivePanel = List.filled(listProducts.length, false);
    notifyListeners();
  } */

  Future<void> deletedCarProduct(int id) async {
    await deleteCarProductsUseCases.deleteCarProduct(id);
    getCarProducts();
  }
}
