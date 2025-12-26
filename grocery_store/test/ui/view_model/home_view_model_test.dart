import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/ui/view_model/old/home_view_model.dart';
import 'package:grocery_store/core/domain/use_cases/product/get_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/send_product_firebase_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/delete_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/update_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/get_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/core/domain/entities/client.dart';
import 'dart:async';

// Manual Mocks/Stubs
class FakeGetProductsUseCases implements NewGetProductsUseCases {
  final _controller = StreamController<List<Product>>();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Stream<List<Product>> callStream() {
    return _controller.stream;
  }

  void emit(List<Product> products) {
    _controller.add(products);
  }

  void dispose() {
    _controller.close();
  }
}

class FakeSendProductFirebaseUseCases implements SendProductFirebaseUseCases {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCreateProductsUseCases implements CreateProductsUseCases {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDeleteProductsUseCases implements NewDeleteProductsUseCases {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  Future<void> deleteProduct(String id) async {}
}

class FakeUpdateProductsUseCases implements UpdateProductsUseCases {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  Future<void> call(Product product) async {}
}

class FakeCreateClientUseCases implements CreateClientUseCases {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGetClientsUseCases implements GetClientsUseCases {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Client>> call() async => [];
}

class FakeDeleteClientsUseCases implements DeleteClientsUseCases {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late HomeViewModel viewModel;
  late FakeGetProductsUseCases fakeGetProductsUseCases;

  setUp(() {
    fakeGetProductsUseCases = FakeGetProductsUseCases();

    viewModel = HomeViewModel(
      getProductsUseCases: fakeGetProductsUseCases,
      sendProductsToFirebaseUseCases: FakeSendProductFirebaseUseCases(),
      createProductsUseCases: FakeCreateProductsUseCases(),
      deleteProductsUseCases: FakeDeleteProductsUseCases(),
      updateProductsUseCases: FakeUpdateProductsUseCases(),
      createClientUseCases: FakeCreateClientUseCases(),
      getClientsUseCases: FakeGetClientsUseCases(),
      deleteClientsUseCases: FakeDeleteClientsUseCases(),
    );
  });

  tearDown(() {
    fakeGetProductsUseCases.dispose();
  });

  group('HomeViewModel Filtering', () {
    test('filterProducts updates listFilterProducts correctly', () async {
      // Arrange
      final products = [
        Product(
          id: '1',
          name: 'Apple',
          price: 1.0,
          description: 'Fresh apple',
          image: 'url/to/apple.jpg',
          stockQuantity: 10,
          idStock: 'stock_1',
        ),
        Product(
          id: '2',
          name: 'Banana',
          price: 0.5,
          description: 'Fresh banana',
          image: 'url/to/banana.jpg',
          stockQuantity: 20,
          idStock: 'stock_2',
        ),
        Product(
          id: '3',
          name: 'Orange',
          price: 0.8,
          description: 'Fresh orange',
          image: 'url/to/orange.jpg',
          stockQuantity: 15,
          idStock: 'stock_3',
        ),
      ];

      // Simulate stream emission
      fakeGetProductsUseCases.emit(products);

      // Wait for stream to be processed (microtask)
      await Future.delayed(Duration.zero);

      // Act: Filter by "Ban"
      viewModel.filterProducts('Ban');

      // Assert
      expect(viewModel.listFilterProducts.length, 1);
      expect(viewModel.listFilterProducts.first.name, 'Banana');

      // Act: Clear filter
      viewModel.filterProducts('');

      // Assert
      expect(viewModel.listFilterProducts.length, 3);
    });

    test('filterProducts returns empty list if no match provided', () async {
      // Arrange
      final products = [
        Product(
          id: '1',
          name: 'Apple',
          price: 1.0,
          description: 'Fresh apple',
          image: 'url/to/apple.jpg',
          stockQuantity: 10,
          idStock: 'stock_1',
        ),
      ];
      fakeGetProductsUseCases.emit(products);
      await Future.delayed(Duration.zero);

      // Act
      viewModel.filterProducts('Zebra');

      // Assert
      expect(viewModel.listFilterProducts, isEmpty);
    });
  });
}
