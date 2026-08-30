import 'package:fibonanci_app/core/formatters/rupiah_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RupiahInputFormatter Unit Tests', () {
    final formatter = RupiahInputFormatter();

    test('Formats digits into Indonesian thousands separator with dots', () {
      const oldVal = TextEditingValue(text: '10');
      const newVal = TextEditingValue(text: '100000');

      final result = formatter.formatEditUpdate(oldVal, newVal);
      expect(result.text, '100.000');
      expect(result.selection.baseOffset, 7);
    });

    test('Formats millions with multiple dots', () {
      const oldVal = TextEditingValue.empty;
      const newVal = TextEditingValue(text: '15000000');

      final result = formatter.formatEditUpdate(oldVal, newVal);
      expect(result.text, '15.000.000');
    });

    test('Handles backspace and empty inputs gracefully', () {
      const oldVal = TextEditingValue(text: '100.000');
      const newVal = TextEditingValue(text: '');

      final result = formatter.formatEditUpdate(oldVal, newVal);
      expect(result.text, '');
    });

    test('parse static helper extracts clean numeric double', () {
      expect(RupiahInputFormatter.parse('100.000'), 100000.0);
      expect(RupiahInputFormatter.parse('1.500.000'), 1500000.0);
      expect(RupiahInputFormatter.parse(''), 0.0);
    });

    test('format static helper formats integer with dots', () {
      expect(RupiahInputFormatter.format(50000), '50.000');
      expect(RupiahInputFormatter.format(1250000), '1.250.000');
    });
  });
}
