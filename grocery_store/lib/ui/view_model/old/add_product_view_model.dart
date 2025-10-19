import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_create_product_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_get_products_use_cases.dart';

class AddProductViewModel extends ChangeNotifier {
  final NewCreateProductsUseCases createProductsUseCases;
  final NewGetProductsUseCases getProductsUseCases;

  AddProductViewModel({
    required this.createProductsUseCases,
    required this.getProductsUseCases,
  });

  int _id = 0;
  File? galleryImage;
  int _selectedQuantity = 0;
  bool _isLoading = false;
  String? _errorMessage;

  int get id => _id;
  int get selectedQuantity => _selectedQuantity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //SETTERS
  set setID(int value) {
    _id = value;
    notifyListeners();
  }

  set selectedQuantity(int value) {
    _selectedQuantity = value;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  //METHODS
  void initImage(File? image) {
    galleryImage = image;
  }

  void setGalleryImage(File? image) {
    galleryImage = image;
    notifyListeners();
  }

  //SERVICES
  /*  Future<Database> _getSembastDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, _dbName);
    return await databaseFactoryIo.openDatabase(dbPath);
  } */

  Future<void> createProduct(Product product) async {
    setLoading(true);
    setError(null);

    try {
      await createProductsUseCases.call(product);
      setLoading(false);
    } on Exception catch (e) {
      setError('Error al crear el producto: ${e.toString()}');
      log('Error al crear el producto: ${e.toString()}');
      setLoading(false);
      rethrow;
    }
  }

  Future<void> getAllProducts() async {
    setLoading(true);
    setError(null);

    try {
      await getProductsUseCases.call();
      setLoading(false);
    } on Exception catch (e) {
      setError('Error al crear el producto: ${e.toString()}');
      log('Error al crear el producto: ${e.toString()}');
      setLoading(false);
      rethrow;
    }
  }

  /*  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
  }) async {
    Random random = Random();
    int randomNumber = random.nextInt(100000000);

    if (galleryImage != null) {
      await createProductsUseCases.call(
        Product(
          id: randomNumber.toString(),
          name: name,
          description: description,
          price: price,
          stockQuantity: stockQuantity,
          idStock: randomNumber.toString(),
          image: galleryImage!.path,
          quantity: 0,
        ),
      );
    }
    galleryImage = null;
  } */
}
