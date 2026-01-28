import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_get_carts_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cash/create_cash_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cash/delete_car_products_use_cases.dart';

class CheckViewModel extends ChangeNotifier {
  CheckViewModel({
    required this.createCashProductsUseCases,
    required this.getCartsUseCases,
    required this.deleteCashProductsUseCases,
  }) {
    //getCarProducts();
  }

  final CreateCashProductsUseCases createCashProductsUseCases;
  final NewGetCartsUseCases getCartsUseCases;
  final DeleteCashProductsUseCases deleteCashProductsUseCases;

  List<Product> listProducts = [];
  List<Product> get listProductsByCar => listProducts;

  

  /* Future<void> getCarTProducts(String cartId, String ownerId) async {
    await deleteCashProductsUseCases.deleteCashProduct(id);
  } */

  Future<void> deletedCarProduct(int id) async {
    await deleteCashProductsUseCases.deleteCashProduct(id);
  }
}
