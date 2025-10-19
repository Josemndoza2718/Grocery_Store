import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/car/get_car_products_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/cash/create_cash_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/cash/delete_car_products_use_cases.dart';

class CheckViewModel extends ChangeNotifier {
  CheckViewModel({
    required this.createCashProductsUseCases,
    required this.getCarProductsUseCases,
    required this.deleteCashProductsUseCases,
  }) {
    //getCarProducts();
  }

  final CreateCashProductsUseCases createCashProductsUseCases;
  final GetAllCartsUseCases getCarProductsUseCases;
  final DeleteCashProductsUseCases deleteCashProductsUseCases;

  List<Product> listProducts = [];
  List<Product> get listProductsByCar => listProducts;

  /* Future<void> addCheckProduct({
    String? ownerCarName,
    required String status,
  }) async {
    if (listProducts.isNotEmpty) {
      Random random = Random();
      int randomId = random.nextInt(100000000);
      int randomOwnerId = random.nextInt(100000000);

      await createCashProductsUseCases.call(Cart(
        id: randomId,
        ownerId: randomOwnerId,
        ownerCarName: ownerCarName,
        products: listProducts,
        status: status,
      ));
    }
  } */

/*   Future<void> getCarProducts() async {
    listProducts = await getCarProductsUseCases.call();
    notifyListeners();
  }
 */
  Future<void> deletedCarProduct(int id) async {
    await deleteCashProductsUseCases.deleteCashProduct(id);
  }
}
