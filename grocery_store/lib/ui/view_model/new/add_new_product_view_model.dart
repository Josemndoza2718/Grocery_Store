import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/update_products_use_cases.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';

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
    final userId = Prefs.getString(PrefKeys.userId) ?? '';
    final productWithUser = product.copyWith(userId: userId);
    await createProductsUseCases.call(productWithUser);
  }

  Future<void> updateProduct(Product product) async {
    await updateProductsUseCases.call(product);
  }
}
