// ignore_for_file: unnecessary_null_comparison

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/client.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/car/create_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/delete_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/get_car_products_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/car/update_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/get_clients_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/product/get_products_use_cases%20copy.dart';

class CarViewModel extends ChangeNotifier {
  CarViewModel({
    required this.getProductsUseCases,
    required this.getCarProductsUseCases,
    required this.addCarProductsUseCases,
    required this.deleteCarProductsUseCases,
    required this.updateCarProductsUseCases,
    required this.createClientUseCases,
    required this.getClientsUseCases,
    required this.deleteClientsUseCases,
  }) {
    getAllCarts();
    getMoneyConversion();
  }

  //Products
  final GetProductsUseCases getProductsUseCases;
  /* final DeleteProductsUseCases deleteProductsUseCases;
  final UpdateProductsUseCases updateProductsUseCases; */

  //Carts
  final GetAllCartsUseCases getCarProductsUseCases;
  final CreateCarProductsUseCases addCarProductsUseCases;
  final DeleteCarProductsUseCases deleteCarProductsUseCases;
  final UpdateCarProductsUseCases updateCarProductsUseCases;

  //Clients
  final CreateClientUseCases createClientUseCases;
  final GetClientsUseCases getClientsUseCases;
  final DeleteClientsUseCases deleteClientsUseCases;

  List<Product> listProducts = [];
  List<Cart> listCarts = [];
  List<Client> listClients = [];

  List<bool> _isActivePanel = [];

  double _moneyConversion = 0;

  double get moneyConversion => _moneyConversion;
  List<bool> get isActivePanel => _isActivePanel;
  List<Product> get listProductsByCar => listProducts;

  void isActiveListPanel(int index) {
    _isActivePanel[index] = !_isActivePanel[index];
    notifyListeners();
  }

  void onSetQuantityProduct(int id, double value) {
    for (var element in listProducts) {
      if (element.id == id) {
        if (element.stockQuantity > 0 &&
            element.quantity < element.stockQuantity) {
          element.quantity = value;
        }
        notifyListeners();
        return;
      }
    }
  }

  void addQuantityProduct(String productId) {
    // Buscar el producto en todas las categorías
    for (var category in listCarts) {
      for (var product in category.products) {
        if (product.id.toString() == productId) {
          if (product.quantity < product.stockQuantity) {
            product.quantity++;
            notifyListeners(); // Notifica a los oyentes
          }
          return; // Salir una vez encontrado y actualizado
        }
      }
    }
  }

  void removeQuantityProduct(String productId) {
    // Buscar el producto en todas las categorías
    for (var category in listCarts) {
      for (var product in category.products) {
        if (product.id.toString() == productId) {
          if (product.quantity > 0) {
            product.quantity--;
            notifyListeners(); // Notifica a los oyentes
          }
          return; // Salir una vez encontrado y actualizado
        }
      }
    }
  }

  void updateQuantityManually(String value, String productId) {
    double? newQuantity = double.tryParse(value);
    if (newQuantity != null) {
      for (var category in listCarts) {
        for (var product in category.products) {
          if (product.id.toString() == productId) {
            if (newQuantity >= 0 && newQuantity <= product.stockQuantity) {
              product.quantity = newQuantity;
            } else if (newQuantity > product.stockQuantity) {
              product.quantity =
                  product.stockQuantity; // Limitar al stock máximo
            } else {
              product.quantity = 0; // Si es negativo o no válido
            }
            notifyListeners(); // Notifica a los oyentes
            return;
          }
        }
      }
    }
    // Si el valor no es un número o está vacío, no hacemos nada (o podríamos reiniciar a 0)
  }

  void setQuantityProductForm(int index, double value) {
    listProducts[index].quantity = value;
    notifyListeners();
  }

  set moneyConversion(double value) {
    _moneyConversion = value;
    notifyListeners();
  }

  void getMoneyConversion() async {
    double money = await Prefs.getMoneyConversion();
    _moneyConversion = money;
    notifyListeners();
  }

  //Car_Products
  Future<void> createCart({
    required int ownerId,
    required String ownerCarName,
    required Product products,
  }) async {
    List<Product> listProductsInCart = [];
    listProductsInCart.add(products);

    if (ownerId != null &&
        listProductsInCart.isNotEmpty &&
        ownerCarName.isNotEmpty) {
      Random random = Random();
      int randomNumber = random.nextInt(100000000);

      await addCarProductsUseCases.call(
        Cart(
          id: randomNumber,
          ownerId: ownerId,
          ownerCarName: ownerCarName,
          status: 'pending',
          products: listProductsInCart,
        ),
      );
      getAllCarts();
    }
  }

  Future<void> updateCart({
    required int cartId,
    required int ownerId,
    required String ownerCarName,
    required List<Product> products,
  }) async {
    if (cartId != null &&
        ownerId != null &&
        products.isNotEmpty &&
        ownerCarName.isNotEmpty) {
      await updateCarProductsUseCases.updateProduct(
        Cart(
          id: cartId,
          ownerId: ownerId,
          ownerCarName: ownerCarName,
          status: 'pending',
          products: products,
        ),
      );
      getAllCarts();
    }
  }

  Future<void> getAllCarts() async {
    listCarts = await getCarProductsUseCases.call();
    listProducts = await getProductsUseCases.call();
    _isActivePanel = List.filled(listCarts.length, false);
    notifyListeners();
  }

  Future<void> deletedCart(int id) async {
    await deleteCarProductsUseCases.deleteCarProduct(id);
    getAllCarts();
  }

  Future<void> deleteProductCart(int cartId, int productId) async {
    for (var element in listCarts) {
      if (element.id == cartId) {
        element.products.removeWhere((product) => product.id == productId);
        await updateCarProductsUseCases.updateProduct(element);
        notifyListeners();
        break;
      }
    }
    //await deleteProductCartUseCases.deleteProductCart(cartId, productId);
    getAllCarts();
  }
}
