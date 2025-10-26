import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_create_product_use_cases.dart';

class AddNewProductViewModel extends ChangeNotifier {
  final NewCreateProductsUseCases newCreateProductsUseCases;

  AddNewProductViewModel({
    required this.newCreateProductsUseCases,
  });

  File? galleryImage;
  final String _errorMessage = 'Ocurrió un error inesperado.';

  String get errorMessage => _errorMessage;

  //SETTERS
  void setGalleryImage(File? image) {
    galleryImage = image;
    notifyListeners();
  }

  //SERVICES
  Future<void> createProduct(Product product) async {
    await newCreateProductsUseCases.call(product);
  }
}
