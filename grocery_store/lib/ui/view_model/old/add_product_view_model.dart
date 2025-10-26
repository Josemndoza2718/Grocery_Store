import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_create_product_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_get_products_use_cases.dart';

class AddProductViewModel extends ChangeNotifier {
  final NewCreateProductsUseCases createProductsUseCases;
  final NewGetProductsUseCases getProductsUseCases;

  AddProductViewModel({
    required this.createProductsUseCases,
    required this.getProductsUseCases,
  });

  int _id = 0;
  File? galleryImage;
  int _selectedQuantity = 0;
  bool _isLoading = false;
  String? _errorMessage;

  int get id => _id;
  int get selectedQuantity => _selectedQuantity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /* //SETTERS
/*   set setID(int value) {
    _id = value;
    notifyListeners();
  } */

  /* set selectedQuantity(int value) {
    _selectedQuantity = value;
    notifyListeners();
  } */

  /* void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  } */

  /* void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  } */ */

  //METHODS
  void initImage(File? image) {
    galleryImage = image;
  }

  /* void setGalleryImage(File? image) {
    galleryImage = image;
    notifyListeners();
  } */

  //SERVICES

  Future<void> createProduct(Product product) async {
    _isLoading = true;
    //setError(null);

    try {
      await createProductsUseCases.call(product);
      _isLoading = false;
    } on Exception catch (e) {
      //setError('Error al crear el producto: ${e.toString()}');
      log('Error al crear el producto: ${e.toString()}');
      _isLoading = false;
      rethrow;
    }
  }

  Future<void> getAllProducts() async {
    _isLoading = true;
    //setError(null);

    try {
      await getProductsUseCases.call();
      _isLoading = false;
    } on Exception catch (e) {
      //setError('Error al crear el producto: ${e.toString()}');
      log('Error al crear el producto: ${e.toString()}');
      _isLoading = false;
      rethrow;
    }
  }
}
