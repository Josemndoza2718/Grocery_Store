import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';
import 'package:grocery_store/domain/entities/cart.dart';
import 'package:grocery_store/domain/use_cases/sales/get_sales_use_case.dart';

class SalesHistoryViewModel extends ChangeNotifier {
  final GetSalesUseCase getSalesUseCase;

  SalesHistoryViewModel({required this.getSalesUseCase}) {
    _loadSales();
  }

  StreamSubscription<List<Cart>>? _salesSubscription;
  List<Cart> _sales = [];
  bool _isLoading = true;
  double _moneyConversion = 0;

  List<Cart> get sales => _sales;
  bool get isLoading => _isLoading;
  double get moneyConversion => _moneyConversion;

  void _loadSales() async {
    _moneyConversion = await Prefs.getMoneyConversion();
    
    final userId = Prefs.getString(PrefKeys.userId) ?? '';

    _salesSubscription = getSalesUseCase.callStream(userId: userId).listen((salesList) {
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
