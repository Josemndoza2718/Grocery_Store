import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/category.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/category/create_categories_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/category/delete_categories_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/category/update_categories_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/category/get_categories_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/delete_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/get_categories_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/product/update_products_use_cases.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    
    //Categories
    required this.createCategoriesUseCases,
    required this.deleteCategoriesUseCases,
    required this.updateCategoriesUseCases,
    required this.getCategoriesUseCases,
    //Products
    required this.getProductsUseCases,
    required this.createProductsUseCases,
    required this.deleteProductsUseCases,
    required this.updateProductsUseCases,
  }) {
    getCategories();
    getProducts();
  }
  //Cagories
  final GetCategoriesUseCases getCategoriesUseCases;
  final CreateCategoriesUseCases createCategoriesUseCases;
  final DeleteCategoriesUseCases deleteCategoriesUseCases;
  final UpdateCategoriesUseCases updateCategoriesUseCases;

  //Products
  final GetProductsUseCases getProductsUseCases;
  final CreateProductsUseCases createProductsUseCases;
  final DeleteProductsUseCases deleteProductsUseCases;
  final UpdateProductsUseCases updateProductsUseCases;


  List<Category> listCategories = [];
  List<Product> listProducts = [];
  List<Product> listProductsByCategory = [];
  List<Product> listProductsByCar = [];

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


  set moneyConversion(double value) {
    _moneyConversion = value;
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
    listProducts = await getProductsUseCases();
    notifyListeners();
  }

  Future<void> getProductsByCategory(int category) async {
    listProductsByCategory.clear();
    for (var element in listProducts) {
      if (element.categoryId == category) {
        if (!listProductsByCategory.contains(element)) {
          //listProductsByCategory.clear();
          listProductsByCategory.add(element);
        }
      }
    }
    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    await deleteProductsUseCases.deleteProduct(id);
    getProducts();
  }

  Future<void> updateProduct(Product product) async {
    await updateProductsUseCases.updateProduct(product);
    getProducts();
  }

  //Categories
  Future<void> getCategories() async {
    listCategories = await getCategoriesUseCases();
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    await deleteCategoriesUseCases.deleteCategory(id);
    getCategories();
  }

  Future<void> updateCategory(Category category) async {
    await updateCategoriesUseCases.updateCategory(category);
    getCategories();
  }
}
