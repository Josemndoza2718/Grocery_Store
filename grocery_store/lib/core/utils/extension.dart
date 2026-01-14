import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

extension TranslateText on String {
  String get translate {
    // Translating the text using custom extension
    return this.tr();
  }

  String get hardcoded {
    // Used for showing hardcoded text in the app
    return kDebugMode ? "$this📌" : this;
  }
}
