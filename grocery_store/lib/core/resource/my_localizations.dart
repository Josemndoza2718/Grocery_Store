// my_app_localizations.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyLocalizations {
  MyLocalizations(this.locale);

  final Locale locale;
  Map<String, String> _localizedStrings = {};

  static MyLocalizations? of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations);
  }

  static const LocalizationsDelegate<MyLocalizations> delegate =
      _MyAppLocalizationsDelegate();

  // --- Método de carga estático y asíncrono ---
  static Future<MyLocalizations> load(Locale locale) async {
    final MyLocalizations appLocalizations = MyLocalizations(locale);

    // Cargar el archivo JSON desde los assets
    final String jsonString = await rootBundle
        .loadString('lib/core/resource/langs/${locale.languageCode}.json');

    // Decodificar el JSON y guardarlo en el mapa
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    appLocalizations._localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));

    return appLocalizations;
  }

  // ... (El resto de la clase se mantiene)

  String translate(String key) {
    return _localizedStrings[key] ?? '!!$key!!';
  }
}

// Delegado de localización
class _MyAppLocalizationsDelegate
    extends LocalizationsDelegate<MyLocalizations> {
  const _MyAppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<MyLocalizations> load(Locale locale) {
    // Llama al nuevo método load que carga el JSON
    return MyLocalizations.load(locale);
  }

  @override
  bool shouldReload(_MyAppLocalizationsDelegate old) {
    return false;
  }
}
