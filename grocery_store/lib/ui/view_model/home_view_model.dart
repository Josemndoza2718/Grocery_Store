import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/category.dart';
import 'package:grocery_store/domain/use_cases/create_categories_use_cases.dart';
import 'package:grocery_store/domain/use_cases/get_categories_use_cases.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this.createCategoriesUseCases,
    required this.getCategoriesUseCases,
  }){
    getCategories();
}
  final GetCategoriesUseCases getCategoriesUseCases;
  final CreateCategoriesUseCases createCategoriesUseCases;

  List<Category> listCategories = [];

  Future<void> getCategories() async {
    listCategories = await getCategoriesUseCases();
    notifyListeners();
  }

  
}
