import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Dynamic real-time thousands separator formatter for IDR amounts.
/// Automatically formats user input (e.g. "100000" -> "100.000", "1500000" -> "1.500.000").
class RupiahInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Strip everything except digits
    final cleanDigits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanDigits.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    final number = int.tryParse(cleanDigits);
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Extracts numeric double from formatted text (e.g. "100.000" -> 100000.0)
  static double parse(String formattedText) {
    final clean = formattedText.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  /// Formats raw numeric value into thousands separated string (e.g. 100000 -> "100.000")
  static String format(num value) {
    return _formatter.format(value.toInt());
  }
}
