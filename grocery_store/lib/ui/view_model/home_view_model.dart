import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/category.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/use_cases/category/create_categories_use_cases.dart';
import 'package:grocery_store/domain/use_cases/category/delete_categories_use_cases.dart';
import 'package:grocery_store/domain/use_cases/category/update_categories_use_cases.dart';
import 'package:grocery_store/domain/use_cases/category/get_categories_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/get_categories_use_cases%20copy.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel( {
    required this.createCategoriesUseCases,
    required this.deleteCategoriesUseCases,
    required this.updateCategoriesUseCases,
    required this.getCategoriesUseCases,
    required this.getProductsUseCases,
  }){
    getCategories();
}
  //Cagories
  final GetCategoriesUseCases getCategoriesUseCases;
  final CreateCategoriesUseCases createCategoriesUseCases;
  final DeleteCategoriesUseCases deleteCategoriesUseCases;
  final UpdateCategoriesUseCases updateCategoriesUseCases;

  final GetProductsUseCases getProductsUseCases;

  

  List<Category> listCategories = [];
  List<Product> listProducts = [];
  

  int _selectedIndexGrid = 0;
  int _pressedIndex = 0;

  String _selectedCategory = '';

  int get pressedIndex => _pressedIndex;
  int get selectedIndexGrid => _selectedIndexGrid;
  String get selectedCategory => _selectedCategory;

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


  Future<void> getProducts() async {
    listProducts = await getProductsUseCases();
    notifyListeners();
  }
  Future<void> initProductsList() async {
    listProducts = await getProductsUseCases();
    
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
