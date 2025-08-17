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

  int _id = 0;

  int get id => _id;

  File? galleryImage;

  int _selectedQuantity = 0;

  int get selectedQuantity => _selectedQuantity;

  set setID(int value) {
    _id = value;
    notifyListeners();
  }

  set selectedQuantity(int value) {
    _selectedQuantity = value;
    notifyListeners();
  }

  void setGalleryImage(File? image) {
    galleryImage = image;
    notifyListeners();
  }

  void initImage(File? image) {
    galleryImage = image;
  }

  Future<void> getCategoryId(List<Product> listProducts, int index) async {
    if (index >= 0 && index <= listProducts.length) {
      for (var element in listProducts) {
        _id = element.id;
        notifyListeners(); //
      }
    }
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
          idStock: selectedQuantity,
          image: galleryImage!.path,
          quantity: 0,
        ),
      );
    }
    galleryImage = null;
  }
}
