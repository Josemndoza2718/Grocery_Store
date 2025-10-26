import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_create_product_use_cases.dart';

class HomeNewViewModel extends ChangeNotifier {
  //Products
  final NewCreateProductsUseCases newCreateProductsUseCases;
  //final DeleteProductsUseCases deleteProductsUseCases;

  HomeNewViewModel({
    required this.newCreateProductsUseCases,
  });

  /* Future<void> deleteProduct(String id) async {
    await deleteProductsUseCases.deleteProduct(id);
    getProducts();
  } */
}
