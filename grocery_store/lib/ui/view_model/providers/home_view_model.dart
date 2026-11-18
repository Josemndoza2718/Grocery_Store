import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/errors/failure.dart';
import 'package:grocery_store/domain/entities/client.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/get_clients_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/delete_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/get_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/update_products_use_cases.dart';
import 'package:uuid/uuid.dart';

class HomeViewModel extends ChangeNotifier {
  StreamSubscription<List<Product>>? _productsSubscription;
  StreamSubscription<List<Client>>? _clientsSubscription;
  //Products
  final NewGetProductsUseCases getProductsUseCases;
  final CreateProductsUseCases createProductsUseCases;
  final NewDeleteProductsUseCases deleteProductsUseCases;
  final UpdateProductsUseCases updateProductsUseCases;

  //Clients
  final CreateClientUseCases createClientUseCases;
  final GetClientsUseCases getClientsUseCases;
  final DeleteClientsUseCases deleteClientsUseCases;

  /// Firebase Auth UID of the logged-in store member.
  final String userId;

  HomeViewModel({
    required this.userId,
    //Products
    required this.getProductsUseCases,
    required this.createProductsUseCases,
    required this.deleteProductsUseCases,
    required this.updateProductsUseCases,
    //Clients
    required this.createClientUseCases,
    required this.getClientsUseCases,
    required this.deleteClientsUseCases,
  }) {
    getProducts();
    getClients();
  }

  List<Product> listProducts = [];
  List<Product> listFilterProducts = [];

  List<Client> listClients = [];
  bool _isActive = false;

  String clientName = "";
  String clientId = "";

  int _selectedIndexGrid = -1;
  int _pressedIndex = -1;

  String _searchQuery = '';

  bool _isFilterList = false;

  int get pressedIndex => _pressedIndex;
  int get selectedIndexGrid => _selectedIndexGrid;
  bool get isFilterList => _isFilterList;
  bool get isActive => _isActive;

  /// True if a client with [name] already exists (case/space insensitive).
  bool clientExists(String name) {
    final normalized = name.trim().toLowerCase();
    return listClients.any((c) => c.name.trim().toLowerCase() == normalized);
  }

  //Create Client
  /// Creates a client in the active store. The list updates by
  /// itself through the real-time stream. Returns the [Failure] if any.
  Future<Failure?> createClient({
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || clientExists(trimmed)) return null;

    final result = await createClientUseCases.call(
      Client(
        id: const Uuid().v4(),
        userId: userId,
        name: trimmed,
      ),
    );
    return result.fold(
      onSuccess: (_) => null,
      onError: (failure) {
        debugPrint('Error creating client: ${failure.message}');
        return failure;
      },
    );
  }

  /// Subscribes (once) to the real-time list of clients of the store.
  Future<void> getClients() async {
    if (_clientsSubscription != null) return;
    _clientsSubscription = getClientsUseCases.callStream().listen(
      (clients) {
        listClients = clients;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Error listening clients: $error');
      },
    );
  }

  Future<Failure?> deletedClient(String id) async {
    final result = await deleteClientsUseCases.deleteClient(id);
    return result.fold(
      onSuccess: (_) {
        // If the deleted client was the selected one, clear the selection.
        if (clientId == id) {
          clientId = '';
          clientName = '';
          notifyListeners();
        }
        return null;
      },
      onError: (failure) {
        debugPrint('Error deleting client: ${failure.message}');
        return failure;
      },
    );
  }

  set setClientName(String value) {
    clientName = value;
    notifyListeners();
  }

  set setClientId(String value) {
    clientId = value;
    notifyListeners();
  }

  void toggleIsActive() {
    _isActive = !_isActive;
    notifyListeners();
  }

  void initList() {
    listFilterProducts.clear();
    listFilterProducts.addAll(listProducts);
    notifyListeners();
  }

  void filterProducts(String query) {
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      listFilterProducts = List.from(listProducts);
    } else {
      final lowercaseQuery = _searchQuery.toLowerCase();
      listFilterProducts = listProducts.where((product) {
        final matchesName = product.name.toLowerCase().contains(lowercaseQuery);
        final matchesCode =
            product.idStock.toLowerCase().contains(lowercaseQuery);
        return matchesName || matchesCode;
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    initList();
  }

  void setIsFilterList(bool value) {
    _isFilterList = value;
    notifyListeners();
  }

  void setPressedIndex(int index) {
    _pressedIndex = index;
    notifyListeners();
  }

  void setSelectedIndexGrid(int index) {
    _selectedIndexGrid = index;
    notifyListeners();
  }

  //Products
  /// Subscribes (once) to the real-time list of products of the store.
  Future<void> getProducts() async {
    if (_productsSubscription != null) return;
    _productsSubscription = getProductsUseCases.callStream().listen(
      (products) {
        listProducts = products;
        // Re-apply current filter instead of just resetting to full list
        filterProducts(_searchQuery);
      },
      onError: (Object error) {
        debugPrint('Error listening products: $error');
      },
    );
  }

  /// Deletes a product (owner). Returns the [Failure] if any.
  Future<Failure?> deleteProduct(String id) async {
    final result = await deleteProductsUseCases.deleteProduct(id);
    return result.fold(
      onSuccess: (_) => null,
      onError: (failure) {
        debugPrint('Error deleting product: ${failure.message}');
        return failure;
      },
    );
  }

  Future<Failure?> updateProduct(Product product) async {
    final result = await updateProductsUseCases.call(product);
    return result.fold(
      onSuccess: (_) => null,
      onError: (failure) {
        debugPrint('Error updating product: ${failure.message}');
        return failure;
      },
    );
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _clientsSubscription?.cancel();
    super.dispose();
  }
}
