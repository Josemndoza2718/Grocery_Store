import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_create_product_use_cases.dart';

class HomeNewViewModel extends ChangeNotifier {
  //Products
  final NewCreateProductsUseCases newCreateProductsUseCases;

  HomeNewViewModel({
    required this.newCreateProductsUseCases,
  });

  Future<void> createProduct() async {
    await newCreateProductsUseCases.call(
      Product(
        id: '1',
        image: 'image',
        name: 'name',
        description: 'description',
        price: 1.0,
        idStock: '1',
        stockQuantity: 1,
      ),
    );
  }
}
