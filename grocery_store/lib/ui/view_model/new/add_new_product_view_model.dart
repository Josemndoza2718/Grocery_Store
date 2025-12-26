import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_create_product_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_update_products_use_cases.dart';

class AddProductViewModel extends ChangeNotifier {
  final CreateProductsUseCases createProductsUseCases;
  final UpdateProductsUseCases updateProductsUseCases;

  AddProductViewModel({
    required this.createProductsUseCases,
    required this.updateProductsUseCases,
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
    await createProductsUseCases.call(product);
  }

  Future<void> updateProduct(Product product) async {
    await updateProductsUseCases.call(product);
  }
}
