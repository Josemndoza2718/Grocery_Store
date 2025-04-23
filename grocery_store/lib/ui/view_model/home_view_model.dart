import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/category.dart';
import 'package:grocery_store/domain/use_cases/category/create_categories_use_cases.dart';
import 'package:grocery_store/domain/use_cases/category/delete_categories_use_cases.dart';
import 'package:grocery_store/domain/use_cases/category/update_categories_use_cases.dart';
import 'package:grocery_store/domain/use_cases/get_categories_use_cases.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this.createCategoriesUseCases,
    required this.deleteCategoriesUseCases,
    required this.updateCategoriesUseCases,
    required this.getCategoriesUseCases,
  }){
    getCategories();
}
  final GetCategoriesUseCases getCategoriesUseCases;
  final CreateCategoriesUseCases createCategoriesUseCases;
  final DeleteCategoriesUseCases deleteCategoriesUseCases;
  final UpdateCategoriesUseCases updateCategoriesUseCases;

  List<Category> listCategories = [];

  int _selectedIndexGrid = 0;
  int _pressedIndex = 0;

  int get pressedIndex => _pressedIndex;
  int get selectedIndexGrid => _selectedIndexGrid;

 void setPressedIndex(int index) {
    _pressedIndex = index;
    notifyListeners();
  }

  void setSelectedIndexGrid(int index) {
    _selectedIndexGrid = index;
    notifyListeners();
  }

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
