import 'package:shared_preferences/shared_preferences.dart';

class Prefs {

  static const String _keyMoneyConversion = 'moneyConversion';
 /*  static const String _keySelectedCategory = 'selectedCategory';
  static const String _keyIsFilterList = 'isFilterList'; */

  static Future<void> setMoneyConversion(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMoneyConversion, value);
  }

  static Future<double> getMoneyConversion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMoneyConversion) ?? 0.0;
  }

 /*  static Future<void> setSelectedCategory(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedCategory, value);
  }

  static Future<String?> getSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedCategory);
  }

  static Future<void> setIsFilterList(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFilterList, value);
  }

  static Future<bool> getIsFilterList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFilterList) ?? false;
  } */
  
}