import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/errors/failure.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_create_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_delete_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_get_carts_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_update_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/get_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/update_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/sales/process_payment_use_case.dart';
import 'package:uuid/uuid.dart';

class CartViewModel extends ChangeNotifier {
  StreamSubscription<List<Cart>>? _cartsSubscription;
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(milliseconds: 1500);

  CartViewModel({
    required this.userId,
    this.userName = '',
    required this.getProductsUseCases,
    required this.getCartsUseCases,
    required this.createCartUseCases,
    required this.deleteCartUseCases,
    required this.updateCartUseCases,
    required this.updateProductsUseCases,
    required this.processPaymentUseCase,
  }) {
    getAllCarts();
  }

  /// Firebase Auth UID of the logged-in store member. The view model is
  /// recreated for every session (user + store).
  final String userId;

  /// Display name of the logged-in member (stored as the seller of a sale).
  final String userName;

  //Products
  final NewGetProductsUseCases getProductsUseCases;
  final UpdateProductsUseCases updateProductsUseCases;

  //Carts
  final NewGetCartsUseCases getCartsUseCases;
  final NewCreateCartUseCases createCartUseCases;
  final NewDeleteCartUseCases deleteCartUseCases;
  final NewUpdateCartUseCases updateCartUseCases;

  //Sales
  final ProcessPaymentUseCase processPaymentUseCase;

  List<Product> listProducts = [];
  List<Cart> listCarts = [];
  List<Cart> filterlistCarts = [];
  List<Cart> paymentlistCarts = [];
  List<Product> listProductsAddCart = [];
  Cart? _selectedCartForCheckout;
  double _subTotal = 0;

  List<bool> _isActivePanel = [];

  final List<String> _hiddenCartIds = [];

  final int _payPart = 0;
  double _discount = 0;
  double _delivery = 0;
  bool _isPaid = false;

  double get subTotal => _subTotal;
  int get payPart => _payPart;
  List<bool> get isActivePanel => _isActivePanel;
  List<Product> get listProductsByCar => listProducts;
  Cart? get selectedCartForCheckout => _selectedCartForCheckout;
  double get discount => _discount;
  double get delivery => _delivery;
  bool get isPaid => _isPaid;

  List<Cart> get paidCarts =>
      listCarts.where((c) => c.status == 'paid').toList();
  List<Cart> get visibleCarts => listCarts
      .where((c) => !_hiddenCartIds.contains(c.id) && c.status != 'paid')
      .toList();

  setIsPaid(bool value) {
    _isPaid = value;
    notifyListeners();
  }

  setDiscount(double value) {
    _discount = value;
    notifyListeners();
  }

  setDelivery(double value) {
    _delivery = value;
    notifyListeners();
  }

  void isActiveListPanel(int index) {
    _isActivePanel[index] = !_isActivePanel[index];
    notifyListeners();
  }

  void onSetQuantityProduct(int id, int value) {
    for (var element in listProducts) {
      if (element.id.toString() == id.toString()) {
        if (element.stockQuantity > 0 &&
            element.quantityToBuy < element.stockQuantity) {
          element.quantityToBuy = value;
        }
        notifyListeners();
        return;
      }
    }
  }

  void addQuantityProduct(String productId, String cartId) {
    // Buscar el producto en todas las categorías
    for (var category in listCarts) {
      if (category.id == cartId) {
        for (var product in category.products) {
          if (product.id.toString() == productId) {
            if (product.quantityToBuy < product.stockQuantity) {
              product.quantityToBuy++;
              // Notifica a los oyentes
            } // Salir una vez encontrado y actualizado
          }
        }
      }
    }
    notifyListeners();
    _saveCartDebounced(cartId);
  }

  void removeQuantityProduct(String productId, String cartId) {
    // Buscar el producto en todas las categorías
    for (var category in listCarts) {
      if (category.id == cartId) {
        for (var product in category.products) {
          if (product.id.toString() == productId) {
            if (product.quantityToBuy > 0) {
              product.quantityToBuy--;
            }
          }
        }
      }
    }
    notifyListeners(); // Notifica a los oyentes
    _saveCartDebounced(cartId);
  }

  void updateQuantityManually(String value, String productId, String cartId) {
    int? newQuantity = int.tryParse(value);
    if (newQuantity != null) {
      for (var cart in listCarts) {
        if (cart.id == cartId) {
          for (var product in cart.products) {
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
    }
    notifyListeners();
    _saveCartDebounced(cartId);
  }

  void setQuantityProductForm(int index, int value) {
    listProducts[index].quantityToBuy = value;
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
      } else {
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

  void prepareCartForCheckout(String cartId) {
    _hiddenCartIds.add(cartId); // Hide cart from list
    _selectedCartForCheckout = null;

    for (var cart in listCarts) {
      if (cart.id == cartId) {
        // Actualizar el stock de los productos (restar quantityToBuy)
        List<Product> updatedProducts = [];
        for (var product in cart.products) {
          int newStock = product.stockQuantity - product.quantityToBuy;
          updatedProducts.add(product.copyWith(stockQuantity: newStock));
        }

        // Crear copia del carrito con los productos actualizados
        _selectedCartForCheckout = cart.copyWith(products: updatedProducts);
        break;
      }
    }
    notifyListeners();
  }

  void getSubTotal(String cartId) {
    _subTotal = 0; // Reiniciar subtotal
    for (var element in listCarts) {
      if (element.id == cartId) {
        _subTotal += element.products
            .where((product) => product.quantityToBuy > 0)
            .map((product) => product.price * product.quantityToBuy)
            .fold(0.0, (previousValue, element) => previousValue + element);
        break;
      }
    }
    notifyListeners();
  }

  void _saveCartDebounced(String cartId) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(_debounceDuration, () async {
      final cartIndex = listCarts.indexWhere((c) => c.id == cartId);
      if (cartIndex != -1) {
        final cart = listCarts[cartIndex];
        await updateCartUseCases.call(cart);
      }
    });
  }

  //Car_Products
  Future<void> createCart({
    required String ownerId,
    required String ownerCarName,
    required Product products,
  }) async {
    List<Product> listProductsInCart = [];
    // Create a defensive copy starting with quantity 1
    listProductsInCart.add(products.copyWith(quantity: 1));

    if (listProductsInCart.isNotEmpty && ownerCarName.isNotEmpty) {
      final cartId = const Uuid().v4();

      final result = await createCartUseCases.call(
        Cart(
          id: cartId,
          userId: userId,
          ownerId: ownerId,
          ownerCarName: ownerCarName,
          status: 'pending',
          products: listProductsInCart,
          createdBy: userId,
        ),
      );

      result.fold(
        onSuccess: (_) {
          // Success logic (no need to do anything as stream updates)
        },
        onError: (failure) {
          // Handle error (maybe set a local error state or notify UI via a callback/listener if architecture allows)
          print('Error creating cart: ${failure.message}');
        },
      );
    }
  }

  Future<bool> updateCart({
    required String cartId,
    required String ownerId,
    required String ownerCarName,
    required Product products,
  }) async {
    //listProductsAddCart.clear();

    for (var element in listCarts) {
      if (element.id == cartId) {
        // Validación: Verificar si el producto ya existe
        if (element.products.any((p) => p.id == products.id)) {
          return false; // Ya existe en el carrito
        }

        listProductsAddCart = List<Product>.from(element.products);
        // Create a defensive copy starting with quantity 1
        listProductsAddCart.add(products.copyWith(quantity: 1));

        final result = await updateCartUseCases.call(
          element.copyWith(
            products: listProductsAddCart,
            updatedAt: DateTime.now(),
          ),
        );

        return result.fold(
          onSuccess: (_) {
            notifyListeners();
            return true;
          },
          onError: (failure) {
            print('Error updating cart: ${failure.message}');
            return false;
          },
        );
      } else {
        //print("No Agregado al carrito ${element.id}");
      }
    }

    notifyListeners();
    return false; // No se encontró el carrito o fallo
  }

  Future<void> getAllCarts() async {
    // Subscribe to carts stream for real-time updates
    await _cartsSubscription?.cancel();
    _cartsSubscription = getCartsUseCases.callStream().listen(
      (carts) {
        listCarts = carts;
        _isActivePanel = List.filled(listCarts.length, false);
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Error listening carts: $error');
      },
    );

    final result = await getProductsUseCases.call();
    result.fold(
      onSuccess: (products) {
        listProducts = products;
        notifyListeners();
      },
      onError: (failure) {
        debugPrint('Error fetching products: ${failure.message}');
      },
    );
  }

  Future<void> deletedCart(String id) async {
    final result = await deleteCartUseCases.call(id);
    result.fold(
      onSuccess: (_) {},
      onError: (failure) => print('Error deleting cart: ${failure.message}'),
    );
  }

  Future<void> updateProductCart(String cartId, String productId) async {
    for (var element in listCarts) {
      if (element.id == cartId) {
        element.products.removeWhere((product) => product.id == productId);
        element.updatedAt = DateTime.now();

        final result = await updateCartUseCases.call(element);

        result.fold(
          onSuccess: (_) => notifyListeners(),
          onError: (failure) =>
              print('Error updating product in cart: ${failure.message}'),
        );
        break;
      }
    }
  }

  @override
  void dispose() {
    _cartsSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Processes the payment of [cartId] atomically (stock, sale, cart).
  ///
  /// The store's [iva] (%) and [exchangeRate] and the current discount (%)
  /// and delivery (USD) are stored in the sale, together with the seller.
  ///
  /// Returns `null` on success or the [Failure] that prevented the payment
  /// (e.g. [StockFailure] when there is not enough stock), so the UI can
  /// inform the user.
  Future<Failure?> markCartAsPaid(
    String cartId, {
    double iva = 0,
    double exchangeRate = 0,
  }) async {
    final index = listCarts.indexWhere((c) => c.id == cartId);
    if (index == -1) {
      return const UnknownFailure(
          message: 'No se encontró el carrito a cobrar');
    }

    // Drop any pending debounced save: the sale is built from the current state.
    _debounceTimer?.cancel();

    final cart = listCarts[index];
    final sale = CheckoutData(
      iva: iva,
      discount: _discount,
      delivery: _delivery,
      exchangeRate: exchangeRate,
    ).applyTo(
      cart,
      soldBy: userId,
      soldByName: userName,
      now: DateTime.now(),
    );

    final result = await processPaymentUseCase.call(cart, sale);

    return result.fold(
      onSuccess: (_) {
        _hiddenCartIds.remove(cartId);
        notifyListeners();
        return null;
      },
      onError: (failure) {
        debugPrint('Error processing payment: ${failure.message}');
        return failure;
      },
    );
  }

  /// Makes a cart visible again in the cart list (e.g. after a failed payment).
  void restoreCartToList(String cartId) {
    _hiddenCartIds.remove(cartId);
    notifyListeners();
  }

  void clearData() {
    _selectedCartForCheckout = null;
    _subTotal = 0;
    _isPaid = false;
    _discount = 0;
    _delivery = 0;
    notifyListeners();
  }
}
