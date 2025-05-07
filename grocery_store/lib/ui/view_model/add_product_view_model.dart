import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/product/create_product_use_cases.dart';

class AddProductViewModel extends ChangeNotifier {
  AddProductViewModel({
    required this.createProductsUseCases,
  });

  final CreateProductsUseCases createProductsUseCases;
  

  

  File? galleryImage;

  void setGalleryImage(File? image) {
    galleryImage = image;
    notifyListeners();
  }

  void initImage(File? image) {
    galleryImage = image;
  }


  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    required double stockQuantity,
    required String category,
  }) async {
    Random random = Random();
    int randomNumber = random.nextInt(100000000);

    if (galleryImage != null) {
      await createProductsUseCases.call(
        Product(
          id: randomNumber,
          name: name,
          description: description,
          price: price,
          stockQuantity: stockQuantity,
          category: category,
          image: galleryImage!.path,
        ),
      );
    }
    galleryImage = null;
  }
}
