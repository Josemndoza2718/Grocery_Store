import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/domain/entities/client.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/car/create_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/delete_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/get_car_products_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/car/update_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/get_clients_use_cases%20copy.dart';

class ShopViewModel extends ChangeNotifier {
  ShopViewModel({
    required this.getCarProductsUseCases,
    required this.createCarProductsUseCases,
    required this.deleteCarProductsUseCases,
    required this.updateCarProductsUseCases,
    required this.createClientUseCases,
    required this.getClientsUseCases,
    required this.deleteClientsUseCases,
  }) {
    getCarProducts();
    getClients();
    getMoneyConversion();
  }

  final GetCarProductsUseCases getCarProductsUseCases;
  final CreateCarProductsUseCases createCarProductsUseCases;
  final DeleteCarProductsUseCases deleteCarProductsUseCases;
  final UpdateCarProductsUseCases updateCarProductsUseCases;

  //Clients
  final CreateClientUseCases createClientUseCases;
  final GetClientsUseCases getClientsUseCases;
  final DeleteClientsUseCases deleteClientsUseCases;

  List<Product> listProducts = [];
  List<Client> listClients = [];

  double _moneyConversion = 0;
  double _quantityProduct = 0;
  bool _isActive = false;

  double get moneyConversion => _moneyConversion;
  double get quantityProduct => _quantityProduct;
  bool get isActive => _isActive;

  Future<void> createClient({
    required String name,
  }) async {
    Random random = Random();
    int randomNumber = random.nextInt(100000000);

    await createClientUseCases.call(
      Client(
        id: randomNumber,
        name: name,
      ),
    );
  }

  Future<void> getClients() async {
    listClients = await getClientsUseCases.call();
    notifyListeners();
  }

  Future<void> deletedClient(int id) async {
    await deleteClientsUseCases.deleteClient(id);
    getCarProducts();
  }

  set isActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  void addQuantityProduct(int index) {
    if (listProducts[index].stockQuantity > 0 && listProducts[index].quantity < listProducts[index].stockQuantity) {
          listProducts[index].quantity ++;
        }
    notifyListeners();
  }

  void removeQuantityProduct(int index) {
     if (listProducts[index].quantity > 0 ) {
          listProducts[index].quantity --;
        }
    notifyListeners();
  }

  void setQuantityProductForm(int index , double value) {
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
  Future<void> addProductByCar(Product product) async {
    if (product.stockQuantity > 0) {
      await createCarProductsUseCases.call(product);
    }
  }

  Future<void> getCarProducts() async {
    listProducts = await getCarProductsUseCases.call();
    notifyListeners();
  }

  Future<void> deletedCarProduct(int id) async {
    await deleteCarProductsUseCases.deleteCarProduct(id);
    //listProductsByCar.remove(id);
    getCarProducts();
  }
}
