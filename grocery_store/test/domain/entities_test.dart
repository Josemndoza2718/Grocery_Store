import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_store/core/errors/failure.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/entities/client.dart';
import 'package:grocery_store/domain/entities/product.dart';

Product _product({String id = 'p1', int stock = 10, int qty = 2}) => Product(
      id: id,
      userId: 'u1',
      name: 'Harina',
      description: 'Harina de maíz 1kg',
      price: 1.5,
      image: 'https://example.com/harina.png',
      idStock: 'H-001',
      stockQuantity: stock,
      quantityToBuy: qty,
      createdAt: DateTime(2026, 1, 2, 3, 4, 5),
    );

void main() {
  group('Product', () {
    test('toJson/fromJson round trip keeps every field', () {
      final original = _product();
      final copy = Product.fromJson(original.toJson());

      expect(copy.id, original.id);
      expect(copy.userId, original.userId);
      expect(copy.name, original.name);
      expect(copy.description, original.description);
      expect(copy.price, original.price);
      expect(copy.image, original.image);
      expect(copy.idStock, original.idStock);
      expect(copy.stockQuantity, original.stockQuantity);
      expect(copy.quantityToBuy, original.quantityToBuy);
      expect(copy.createdAt, original.createdAt);
    });

    test('copyWith only changes the given fields', () {
      final original = _product();
      final changed = original.copyWith(stockQuantity: 3, quantity: 1);

      expect(changed.stockQuantity, 3);
      expect(changed.quantityToBuy, 1);
      expect(changed.name, original.name);
      expect(changed.createdAt, original.createdAt);
    });

    test('equality is based on id', () {
      expect(_product(id: 'a', qty: 1), _product(id: 'a', qty: 5));
      expect(_product(id: 'a') == _product(id: 'b'), isFalse);
    });
  });

  group('Cart', () {
    test('toJson/fromJson round trip keeps products and dates', () {
      final original = Cart(
        id: 'c1',
        userId: 'u1',
        ownerId: 'client-1',
        ownerCarName: 'María',
        status: 'pending',
        products: [_product(id: 'p1'), _product(id: 'p2', qty: 4)],
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 2),
      );
      final copy = Cart.fromJson(original.toJson());

      expect(copy.id, 'c1');
      expect(copy.ownerId, 'client-1');
      expect(copy.ownerCarName, 'María');
      expect(copy.products.map((p) => p.id), ['p1', 'p2']);
      expect(copy.products[1].quantityToBuy, 4);
      expect(copy.createdAt, original.createdAt);
      expect(copy.updatedAt, original.updatedAt);
      expect(copy.payAt, isNull);
    });

    test('fromJson accepts legacy snake_case keys and numeric ownerId', () {
      final cart = Cart.fromJson({
        'id': 'c2',
        'owner_id': 7,
        'owner_car_name': 'Pedro',
        'products': <dynamic>[],
      });

      expect(cart.ownerId, '7');
      expect(cart.ownerCarName, 'Pedro');
      expect(cart.status, 'pending');
      expect(cart.products, isEmpty);
    });
  });

  group('Client', () {
    test('toJson/fromJson round trip', () {
      final original = Client(
        id: 'cl1',
        userId: 'u1',
        name: 'Ana',
        createdAt: DateTime(2026, 3, 3),
      );
      final copy = Client.fromJson(original.toJson());

      expect(copy.id, 'cl1');
      expect(copy.userId, 'u1');
      expect(copy.name, 'Ana');
      expect(copy.createdAt, original.createdAt);
    });

    test('fromJson tolerates missing optional fields', () {
      final client = Client.fromJson({'id': 5, 'name': 'Luis'});
      expect(client.id, '5');
      expect(client.userId, '');
    });
  });

  group('Result', () {
    test('fold dispatches on success and error', () {
      const Result<int> ok = Success(3);
      const Result<int> ko = Error(StockFailure(message: 'sin stock'));

      expect(ok.fold(onSuccess: (v) => 'ok $v', onError: (f) => f.message),
          'ok 3');
      expect(ko.fold(onSuccess: (v) => 'ok $v', onError: (f) => f.message),
          'sin stock');
      expect(ko.getOrElse(0), 0);
    });
  });
}
