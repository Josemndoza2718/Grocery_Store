import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/update_products_use_cases.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
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
    
    final result = await createProductsUseCases.call(productWithUser);
    
    result.fold(
      onSuccess: (_) {},
      onError: (failure) {
         // In a real app, we might want to expose this failure to the UI
         print('Error creating product: ${failure.message}');
      },
    );
  }

  Future<void> updateProduct(Product product) async {
    final result = await updateProductsUseCases.call(product);
    
    result.fold(
      onSuccess: (_) {},
      onError: (failure) {
        print('Error updating product: ${failure.message}');
      },
    );
  }

  void clearData(){
    galleryImage = null;
    notifyListeners();
  }
}
