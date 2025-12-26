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
import 'package:grocery_store/core/domain/use_cases/client/get_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/get_products_use_cases.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel({
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
  final NewGetProductsUseCases getProductsUseCases;
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
  List<Cart> filterlistCarts = [];
  List<Client> listClients = [];
  List<Product> listProductsAddCart = [];

  List<bool> _isActivePanel = [];

  double _moneyConversion = 0;
  int _payPart = 0;

  double get moneyConversion => _moneyConversion;
  int get payPart => _payPart;
  List<bool> get isActivePanel => _isActivePanel;
  List<Product> get listProductsByCar => listProducts;

  void isActiveListPanel(int index) {
    _isActivePanel[index] = !_isActivePanel[index];
    notifyListeners();
  }

  void onSetQuantityProduct(int id, int value) {
    for (var element in listProducts) {
      if (element.id == id) {
        if (element.stockQuantity > 0 &&
            element.quantityToBuy < element.stockQuantity) {
          element.quantityToBuy = value;
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
          if (product.quantityToBuy < product.stockQuantity) {
            product.quantityToBuy++;
            // Notifica a los oyentes
          } // Salir una vez encontrado y actualizado
        }
      }
    }
    notifyListeners();
  }

  void removeQuantityProduct(String productId) {
    // Buscar el producto en todas las categorías
    for (var category in listCarts) {
      for (var product in category.products) {
        if (product.id.toString() == productId) {
          if (product.quantityToBuy > 0) {
            product.quantityToBuy--;
          }
        }
      }
    }
    notifyListeners(); // Notifica a los oyentes
  }

  void updateQuantityManually(String value, String productId) {
    int? newQuantity = int.tryParse(value);
    if (newQuantity != null) {
      for (var category in listCarts) {
        for (var product in category.products) {
          if (product.id.toString() == productId) {
            if (newQuantity >= 0 && newQuantity <= product.stockQuantity) {
              product.quantityToBuy = newQuantity;
            } else if (newQuantity > product.stockQuantity) {
              product.quantityToBuy =
                  product.stockQuantity; // Limitar al stock máximo
            } else {
              product.quantityToBuy = 0; // Si es negativo o no válido
            }
          }
        }
      }
    }
    notifyListeners();
    // Si el valor no es un número o está vacío, no hacemos nada (o podríamos reiniciar a 0)
  }

  void setQuantityProductForm(int index, int value) {
    listProducts[index].quantityToBuy = value;
    notifyListeners();
  }

  set moneyConversion(double value) {
    _moneyConversion = value;
    notifyListeners();
  }

  void onSetPayProduct(int id, int value) {
    for (var element in listCarts) {
      if (element.id == id) {
        element.status = "paypart";
        element.payPart = value;
        notifyListeners();
      }
    }
  }

  void setListPayProduct() {
    //filterlistCarts.clear();
    for (var element in listCarts) {
      if (element.status != 'pending') {
        filterlistCarts.add(element);
      }
    }
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
    required Product products,
  }) async {
    //listProductsAddCart.clear();

    for (var element in listCarts) {
      if (element.id == cartId) {
        listProductsAddCart = List<Product>.from(element.products);
        listProductsAddCart.add(products);
        await updateCarProductsUseCases.updateProduct(
          Cart(
            id: cartId,
            ownerId: ownerId,
            ownerCarName: ownerCarName,
            status: 'pending',
            products: listProductsAddCart,
          ),
        );
        getAllCarts();
      } else {
        print("No Agregado");
      }
    }

    notifyListeners();
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

  Future<void> updateProductCart(int cartId, String productId) async {
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
