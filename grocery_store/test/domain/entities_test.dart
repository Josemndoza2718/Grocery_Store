import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_store/core/errors/failure.dart';
import 'package:grocery_store/core/errors/result.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/entities/client.dart';
import 'package:grocery_store/domain/entities/invitation.dart';
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

  group('CheckoutData', () {
    test('computes subtotal, IVA, discount and delivery in USD', () {
      final cart = Cart(
        id: 'c1',
        ownerId: 'cl1',
        products: [
          _product(id: 'p1', qty: 2), // 2 x 1.5 = 3.0
          _product(id: 'p2', qty: 0), // ignored
          _product(id: 'p3', qty: 4), // 4 x 1.5 = 6.0
        ],
      );
      final sale = const CheckoutData(
        iva: 16,
        discount: 10,
        delivery: 2,
        exchangeRate: 40,
      ).applyTo(cart,
          soldBy: 'u1', soldByName: 'Ana', now: DateTime(2026, 2, 1));

      expect(sale.subtotal, 9.0);
      // 9 + 16% (1.44) + 2 - 10% (0.9) = 11.54
      expect(sale.total, closeTo(11.54, 1e-9));
      expect(sale.totalItems, 6);
      expect(sale.status, 'paid');
      expect(sale.soldBy, 'u1');
      expect(sale.soldByName, 'Ana');
      expect(sale.exchangeRate, 40);
      expect(sale.payAt, DateTime(2026, 2, 1));
    });

    test('sale fields survive the JSON round trip', () {
      final sale = const CheckoutData(iva: 16, exchangeRate: 40).applyTo(
        Cart(id: 'c1', ownerId: 'cl1', products: [_product()], createdBy: 'u2'),
        soldBy: 'u1',
        soldByName: 'Ana',
        now: DateTime(2026, 2, 1),
      );
      final copy = Cart.fromJson(sale.toJson());
      expect(copy.createdBy, 'u2');
      expect(copy.soldBy, 'u1');
      expect(copy.total, sale.total);
      expect(copy.iva, 16);
      expect(copy.exchangeRate, 40);
    });

    test('legacy sales without stored total fall back to the products subtotal',
        () {
      final legacy = Cart(id: 'old', ownerId: 'cl1', products: [_product()]);
      expect(legacy.total, 0);
      expect(legacy.effectiveTotal, 3.0);
    });
  });

  group('Invitation', () {
    test('generated codes are 8 chars from the unambiguous alphabet', () {
      for (var i = 0; i < 200; i++) {
        final code = Invitation.generateCode();
        expect(Invitation.isWellFormed(code), isTrue, reason: code);
        expect(code, isNot(matches(RegExp('[01OIL]'))));
      }
    });

    test('normalize and format', () {
      expect(Invitation.normalize(' k7m4-qxpa '), 'K7M4QXPA');
      expect(Invitation.format('K7M4QXPA'), 'K7M4-QXPA');
      expect(Invitation.isWellFormed('K7M4QXP'), isFalse);
    });

    test('pending until used or expired', () {
      final now = DateTime(2026, 1, 1, 12);
      final invitation = Invitation(
        code: 'K7M4QXPA',
        storeId: 's1',
        createdBy: 'boss',
        createdAt: now,
        expiresAt: now.add(Invitation.validity),
      );
      expect(invitation.isPending(now), isTrue);
      expect(invitation.isPending(now.add(const Duration(hours: 48))), isFalse);
      expect(
        Invitation(
          code: 'K7M4QXPA',
          storeId: 's1',
          createdBy: 'boss',
          createdAt: now,
          expiresAt: now.add(Invitation.validity),
          usedBy: 'erin',
        ).isPending(now),
        isFalse,
      );
    });
  });
}
