import 'package:flutter/material.dart';
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
  }

  final GetCarProductsUseCases getCarProductsUseCases;
  final CreateCarProductsUseCases createCarProductsUseCases;
  final DeleteCarProductsUseCases deleteCarProductsUseCases;
  final UpdateCarProductsUseCases updateCarProductsUseCases;

  List<Product> listProducts = [];

  int _selectedIndexGrid = -1;
  int _pressedIndex = -1;
  double _moneyConversion = 0;

  String _selectedCategory = '';
  int _selectedCategoryById = 0;

  double get moneyConversion => _moneyConversion;
  int get pressedIndex => _pressedIndex;
  int get selectedIndexGrid => _selectedIndexGrid;
  String get selectedCategory => _selectedCategory;
  int get selectedCategoryById => _selectedCategoryById;

  set moneyConversion(double value) {
    _moneyConversion = value;
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

  void setselectedCategoryById(int categoryId) {
    _selectedCategoryById = categoryId;
    notifyListeners();
  }

  //Car_Products
  Future<void> addProductByCar(Product product) async {
    if (product.stockQuantity > 0) {
      await createCarProductsUseCases.call(product);
      //listProductsByCar.add(product);
    }
  }

  Future<void> getCarProducts() async {
    listProducts = await getCarProductsUseCases();
    notifyListeners();
  }

  Future<void> deletedCarProduct(int id) async {
    await deleteCarProductsUseCases.deleteCarProduct(id);
    //listProductsByCar.remove(id);
    getCarProducts();
  }
}
