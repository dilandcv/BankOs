import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/utils/money_formatter.dart';
import 'package:mobile/shared/utils/thousands_separator_input_formatter.dart';

void main() {
  group('ThousandsSeparatorInputFormatter', () {
    const formatter = ThousandsSeparatorInputFormatter();

    TextEditingValue format(String oldText, String newText, int newCursor) {
      return formatter.formatEditUpdate(
        TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: oldText.length),
        ),
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newCursor),
        ),
      );
    }

    test('agrega comas de miles dinámicamente', () {
      expect(format('', '1', 1).text, '1');
      expect(format('1', '10', 2).text, '10');
      expect(format('10', '100', 3).text, '100');
      expect(format('100', '1000', 4).text, '1,000');
      expect(format('1,000', '10000', 5).text, '10,000');
      expect(format('10,000', '100000', 6).text, '100,000');
      expect(format('100,000', '1000000', 7).text, '1,000,000');
    });

    test('permite punto decimal y hasta 2 decimales', () {
      final withDot = format('1,000', '1,000.', 6);
      expect(withDot.text, '1,000.');

      final withOneDecimal = format('1,000.', '1,000.5', 7);
      expect(withOneDecimal.text, '1,000.5');

      final withTwoDecimals = format('1,000.5', '1,000.50', 8);
      expect(withTwoDecimals.text, '1,000.50');

      // Un tercer decimal es truncado
      final withThreeDecimals = format('1,000.50', '1,000.509', 9);
      expect(withThreeDecimals.text, '1,000.50');
    });

    test('convierte coma manual a punto decimal', () {
      final converted = format('500', '500,', 4);
      expect(converted.text, '500.');
    });

    test('normaliza montos formateados en MoneyFormatter.normalizeInput', () {
      expect(MoneyFormatter.normalizeInput('1,000'), '1000.00');
      expect(MoneyFormatter.normalizeInput('1,234,567.89'), '1234567.89');
      expect(MoneyFormatter.normalizeInput('50.5'), '50.50');
    });
  });
}
