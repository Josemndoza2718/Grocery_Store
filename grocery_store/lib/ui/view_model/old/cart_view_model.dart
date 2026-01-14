import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/domain/entities/cart.dart';
import 'package:grocery_store/core/domain/entities/client.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/cart/new/new_create_cart_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/cart/new/new_delete_cart_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/cart/new/new_get_carts_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/cart/new/new_update_cart_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/get_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/get_products_use_cases.dart';
import 'package:uuid/uuid.dart';

class CartViewModel extends ChangeNotifier {
  StreamSubscription<List<Cart>>? _cartsSubscription;

  CartViewModel({
    required this.getProductsUseCases,
    required this.getCartsUseCases,
    required this.createCartUseCases,
    required this.deleteCartUseCases,
    required this.updateCartUseCases,
    required this.createClientUseCases,
    required this.getClientsUseCases,
    required this.deleteClientsUseCases,
  }) {
    getAllCarts();
    getMoneyConversion();
  }

  //Products
  final NewGetProductsUseCases getProductsUseCases;

  //Carts
  final NewGetCartsUseCases getCartsUseCases;
  final NewCreateCartUseCases createCartUseCases;
  final NewDeleteCartUseCases deleteCartUseCases;
  final NewUpdateCartUseCases updateCartUseCases;

  //Clients
  final CreateClientUseCases createClientUseCases;
  final GetClientsUseCases getClientsUseCases;
  final DeleteClientsUseCases deleteClientsUseCases;

  List<Product> listProducts = [];
  List<Cart> listCarts = [];
  List<Cart> filterlistCarts = [];
  List<Cart> paymentlistCarts = [];
  List<Client> listClients = [];
  List<Product> listProductsAddCart = [];
  double _subTotal = 0;

  List<bool> _isActivePanel = [];

  double _moneyConversion = 0;
  int _payPart = 0;

  double get moneyConversion => _moneyConversion;
  int get payPart => _payPart;
  List<bool> get isActivePanel => _isActivePanel;
  List<Product> get listProductsByCar => listProducts;
  double get subTotal => _subTotal;

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
              product.quantityToBuy = product.stockQuantity; // Limitar al stock máximo
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

  void onSetPayProduct(String id, int value) {
    for (var element in listCarts) {
      if (value > 0) {
        if (element.id == id) {
          element.status = "paypart";
          element.payPart = value;
          element.updatedAt = DateTime.now();
        }
      }
      else{
        if (element.id == id) {
          element.status = "buying";
          element.payAt = null; // Reset payment date if changing back to buying
          element.updatedAt = DateTime.now();
        }
      }
    }
    notifyListeners();
  }

  void setListPayProduct() {
    //filterlistCarts.clear();
    for (var element in listCarts) {
      if (element.status == 'paypart') {
        filterlistCarts.add(element);
      }
      if (element.status != 'buying') {
        paymentlistCarts.add(element);
      }
    }
    notifyListeners();
  }

  /// Prepara un carrito específico para el checkout
  Cart? selectedCartForCheckout;
  
  void prepareCartForCheckout(String cartId) {
    selectedCartForCheckout = null;
    
    for (var cart in listCarts) {
      if (cart.id == cartId) {
        // Actualizar el stock de los productos (restar quantityToBuy)
        List<Product> updatedProducts = [];
        for (var product in cart.products) {
          int newStock = product.stockQuantity - product.quantityToBuy;
          updatedProducts.add(product.copyWith(stockQuantity: newStock));
        }
        
        // Crear copia del carrito con los productos actualizados
        selectedCartForCheckout = cart.copyWith(products: updatedProducts);
        break;
      }
    }
    notifyListeners();
  }

  void getSubTotal() {
    
    for (var element in listCarts) {
      _subTotal += element.products
          .where((product) => product.quantityToBuy > 0)
          .map((product) => product.price * product.quantityToBuy)
          .reduce((a, b) => a + b);
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

    if (listProductsInCart.isNotEmpty && ownerCarName.isNotEmpty) {
      final cartId = const Uuid().v4();

      await createCartUseCases.call(
        Cart(
          id: cartId,
          ownerId: ownerId,
          ownerCarName: ownerCarName,
          status: 'pending',
          products: listProductsInCart,
        ),
      );
      // No need to call getAllCarts() - stream updates automatically
    }
  }

  Future<void> updateCart({
    required String cartId,
    required int ownerId,
    required String ownerCarName,
    required Product products,
  }) async {
    //listProductsAddCart.clear();

    for (var element in listCarts) {
      if (element.id == cartId) {
        listProductsAddCart = List<Product>.from(element.products);
        listProductsAddCart.add(products);
        await updateCartUseCases.call(
          element.copyWith(
            products: listProductsAddCart,
            updatedAt: DateTime.now(),
          ),
        );
        // No need to call getAllCarts() - stream updates automatically
      } else {
        print("No Agregado");
      }
    }

    notifyListeners();
  }

  Future<void> getAllCarts() async {
    // Subscribe to carts stream for real-time updates
    _cartsSubscription?.cancel();
    _cartsSubscription = getCartsUseCases.callStream().listen((carts) {
      listCarts = carts;
      _isActivePanel = List.filled(listCarts.length, false);
      notifyListeners();
    });

    // Get products
    listProducts = await getProductsUseCases.call();
    notifyListeners();
  }

  Future<void> deletedCart(String id) async {
    await deleteCartUseCases.call(id);
    // No need to call getAllCarts() - stream updates automatically
  }

  Future<void> updateProductCart(String cartId, String productId) async {
    for (var element in listCarts) {
      if (element.id == cartId) {
        element.products.removeWhere((product) => product.id == productId);
        element.updatedAt = DateTime.now();
        await updateCartUseCases.call(element);
        // No need to call getAllCarts() - stream updates automatically
        notifyListeners();
        break;
      }
    }
  }

  @override
  void dispose() {
    _cartsSubscription?.cancel();
    super.dispose();
  }
}
