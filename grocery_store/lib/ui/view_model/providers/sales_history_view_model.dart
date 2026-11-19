import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/use_cases/sales/get_sales_use_case.dart';

enum SalesFilter { daily, weekly, monthly }

enum CurrencyType { bs, usd }

/// A store member who charged at least one sale (for the owner's filter).
class Seller {
  final String uid;
  final String name;
  const Seller(this.uid, this.name);
}

class SalesHistoryViewModel extends ChangeNotifier {
  final GetSalesUseCase getSalesUseCase;

  /// Firebase Auth UID of the logged-in store member.
  final String userId;

  /// Owners see every sale of the store; employees only the ones they charged
  /// (also enforced by the security rules).
  final bool canSeeAllSales;

  SalesHistoryViewModel({
    required this.userId,
    required this.canSeeAllSales,
    required this.getSalesUseCase,
  }) {
    _loadSales();
  }

  StreamSubscription<List<Cart>>? _salesSubscription;
  List<Cart> _sales = [];
  bool _isLoading = true;
  String? _errorMessage;
  SalesFilter _selectedFilter = SalesFilter.daily;
  CurrencyType _selectedCurrency = CurrencyType.bs;

  /// Owner filter by seller uid (`null` = all sellers).
  String? _sellerFilter;

  List<Cart> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SalesFilter get selectedFilter => _selectedFilter;
  CurrencyType get selectedCurrency => _selectedCurrency;
  String? get sellerFilter => _sellerFilter;

  /// Sellers that appear in the loaded sales (owner filter options).
  List<Seller> get sellers {
    final byUid = <String, String>{};
    for (final sale in _sales) {
      if (sale.soldBy.isEmpty) continue;
      byUid.putIfAbsent(
        sale.soldBy,
        () => sale.soldByName.isEmpty ? 'Sin nombre' : sale.soldByName,
      );
    }
    return byUid.entries.map((e) => Seller(e.key, e.value)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<Cart> get filteredSales {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime from;
    switch (_selectedFilter) {
      case SalesFilter.daily:
        from = today;
      case SalesFilter.weekly:
        from = today.subtract(Duration(days: today.weekday - 1));
      case SalesFilter.monthly:
        from = DateTime(now.year, now.month, 1);
    }

    return _sales.where((sale) {
      if (_sellerFilter != null && sale.soldBy != _sellerFilter) return false;
      final date = DateTime(
          sale.updatedAt.year, sale.updatedAt.month, sale.updatedAt.day);
      return !date.isBefore(from) && !date.isAfter(today);
    }).toList();
  }

  void setFilter(SalesFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setCurrency(CurrencyType currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  void setSellerFilter(String? uid) {
    _sellerFilter = uid;
    notifyListeners();
  }

  /// Total of [sale] in the selected currency.
  ///
  /// Uses the rate stored in the sale; legacy sales without it fall back to
  /// the store's [currentRate].
  double saleTotal(Cart sale, double currentRate) {
    final usd = sale.effectiveTotal;
    if (_selectedCurrency == CurrencyType.usd) return usd;
    final rate = sale.exchangeRate > 0 ? sale.exchangeRate : currentRate;
    return rate > 0 ? usd * rate : usd;
  }

  /// Sum of the filtered sales in the selected currency.
  double filteredTotal(double currentRate) => filteredSales.fold(
      0.0, (sum, sale) => sum + saleTotal(sale, currentRate));

  String get currencySuffix =>
      _selectedCurrency == CurrencyType.bs ? 'Bs' : '\$';

  void _loadSales() {
    _salesSubscription = getSalesUseCase
        .callStream(soldBy: canSeeAllSales ? null : userId)
        .listen(
      (salesList) {
        _sales = salesList;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Error listening sales history: $error');
        _isLoading = false;
        _errorMessage = 'No se pudo cargar el historial de ventas.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _salesSubscription?.cancel();
    super.dispose();
  }
}
