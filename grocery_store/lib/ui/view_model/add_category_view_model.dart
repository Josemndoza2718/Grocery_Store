import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/category.dart';
import 'package:grocery_store/domain/use_cases/category/create_categories_use_cases.dart';

class AddCategoryViewModel extends ChangeNotifier {
  AddCategoryViewModel({
    required this.createCategoriesUseCases,
  });

  final CreateCategoriesUseCases createCategoriesUseCases;

  File? galleryImage;
  File? cameraImage;

  void setGalleryImage(File? image) {
    galleryImage = image;
    notifyListeners();
  }

   void initImage(File? image) {
    galleryImage = image;
  }

  Future<void> createCategory(String name) async {
    Random random = Random();
    int randomNumber = random.nextInt(100000000);

    if (galleryImage != null) {
      await createCategoriesUseCases.call(
        Category(
          id: randomNumber,
          name: name,
          image: galleryImage!.path,
        ),
      );
    }
    /* else if (cameraImage != null) {
      await createCategoriesUseCases.call(
        Category(
          id: randomNumber,
          name: name,
          image: cameraImage!.path,
        ),
      );
    } */
    galleryImage = null;
    //cameraImage = null;
  }

}
