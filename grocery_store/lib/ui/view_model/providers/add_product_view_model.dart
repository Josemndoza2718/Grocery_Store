import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/update_products_use_cases.dart';

class AddProductViewModel extends ChangeNotifier {
  final CreateProductsUseCases createProductsUseCases;
  final UpdateProductsUseCases updateProductsUseCases;

  /// Firebase Auth UID of the session owner.
  final String userId;

  AddProductViewModel({
    required this.userId,
    required this.createProductsUseCases,
    required this.updateProductsUseCases,
  });

  File? galleryImage;
  String urlImage = '';
  final String _errorMessage = 'Ocurrió un error inesperado.';

  String get errorMessage => _errorMessage;

  //SETTERS
  void setGalleryImage(File? image) {
    galleryImage = image;
    notifyListeners();
  }

  void setUrlImage(String url) {
    urlImage = url;
    notifyListeners();
  }

  //SERVICES
  Future<void> createProduct(Product product) async {
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
    // Always stamp the owner so Firestore rules accept the write.
    final result =
        await updateProductsUseCases.call(product.copyWith(userId: userId));

    result.fold(
      onSuccess: (_) {},
      onError: (failure) {
        print('Error updating product: ${failure.message}');
      },
    );
  }

  void clearData() {
    galleryImage = null;
    notifyListeners();
  }
}
