import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,##0.00", "es_ES");

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Quitar caracteres no numéricos excepto la coma
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Convertir a número con 2 decimales (suponemos que los últimos dos dígitos son decimales)
    double value = double.parse(newText) / 100;

    final formattedText = _formatter.format(value);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
