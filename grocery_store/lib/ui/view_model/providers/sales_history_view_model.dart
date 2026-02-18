import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/use_cases/sales/get_sales_use_case.dart';

enum SalesFilter { daily, weekly, monthly }

enum CurrencyType { bs, usd }

class SalesHistoryViewModel extends ChangeNotifier {
  final GetSalesUseCase getSalesUseCase;

  SalesHistoryViewModel({required this.getSalesUseCase}) {
    _loadSales();
  }

  StreamSubscription<List<Cart>>? _salesSubscription;
  List<Cart> _sales = [];
  bool _isLoading = true;
  double _moneyConversion = 0;
  SalesFilter _selectedFilter = SalesFilter.daily;
  CurrencyType _selectedCurrency = CurrencyType.bs;

  List<Cart> get sales => _sales;
  bool get isLoading => _isLoading;
  double get moneyConversion => _moneyConversion;
  SalesFilter get selectedFilter => _selectedFilter;
  CurrencyType get selectedCurrency => _selectedCurrency;

  List<Cart> get filteredSales {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case SalesFilter.daily:
        return _sales.where((cart) {
          final cartDate = DateTime(
              cart.updatedAt.year, cart.updatedAt.month, cart.updatedAt.day);
          return cartDate == today;
        }).toList();
      case SalesFilter.weekly:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return _sales.where((cart) {
          final cartDate = DateTime(
              cart.updatedAt.year, cart.updatedAt.month, cart.updatedAt.day);
          return !cartDate.isBefore(startOfWeek) && !cartDate.isAfter(today);
        }).toList();
      case SalesFilter.monthly:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return _sales.where((cart) {
          final cartDate = DateTime(
              cart.updatedAt.year, cart.updatedAt.month, cart.updatedAt.day);
          return !cartDate.isBefore(startOfMonth) && !cartDate.isAfter(today);
        }).toList();
    }
  }

  void setFilter(SalesFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setCurrency(CurrencyType currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  double get filteredTotal {
    double total = 0;
    for (var cart in filteredSales) {
      for (var product in cart.products) {
        if (product.quantityToBuy > 0) {
          total += (product.price * product.quantityToBuy);
        }
      }
    }
    if (_selectedCurrency == CurrencyType.bs && _moneyConversion != 0) {
      return total * _moneyConversion;
    }
    return total;
  }

  String get currencySuffix =>
      _selectedCurrency == CurrencyType.bs ? 'Bs' : '\$';

  void _loadSales() async {
    _moneyConversion = await Prefs.getMoneyConversion();

    final userId = Prefs.getString(PrefKeys.userId) ?? '';

    _salesSubscription =
        getSalesUseCase.callStream(userId: userId).listen((salesList) {
      _sales = salesList;
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _salesSubscription?.cancel();
    super.dispose();
  }
}
