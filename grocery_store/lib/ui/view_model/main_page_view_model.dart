import 'package:flutter/material.dart';

class MainPageViewModel extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  

  set setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

 /*  Future<void> onItemTapped(BuildContext context, int index) async {
    _selectedIndex = index;
    notifyListeners();
   
    
  } */
  
}
