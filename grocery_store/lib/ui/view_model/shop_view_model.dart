import 'package:flutter/material.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/car/create_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/delete_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/get_car_products_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/car/update_car_products_use_cases.dart';

class ShopViewModel extends ChangeNotifier {
  ShopViewModel({
    required this.getCarProductsUseCases,
    required this.createCarProductsUseCases,
    required this.deleteCarProductsUseCases,
    required this.updateCarProductsUseCases,
  }) {
    getCarProducts();
    getMoneyConversion();
  }

  final GetCarProductsUseCases getCarProductsUseCases;
  final CreateCarProductsUseCases createCarProductsUseCases;
  final DeleteCarProductsUseCases deleteCarProductsUseCases;
  final UpdateCarProductsUseCases updateCarProductsUseCases;

  List<Product> listProducts = [];

  double _moneyConversion = 0;
  int _quantityProduct = 0;
  bool _isActive = false;

  double get moneyConversion => _moneyConversion;
  int get quantityProduct => _quantityProduct;
  bool get isActive => _isActive;
  
  set isActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  void addQuatityProduct() {
    _quantityProduct++;
    notifyListeners();
  }

  set quantityProduct(int value) {
    _quantityProduct = value;
    notifyListeners();
  }

  void removeQuatityProduct() {
    if (quantityProduct > 0) {
      _quantityProduct--;
    }
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
