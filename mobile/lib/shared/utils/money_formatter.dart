import 'package:decimal/decimal.dart';

/// Toda cantidad viaja como `String`; las operaciones usan `Decimal`.
class MoneyFormatter {
  MoneyFormatter._();

  static const Map<String, String> _symbols = <String, String>{
    'USD': '\$',
    'EUR': '€',
  };

  static String format(
    String raw, {
    String currency = '',
    bool signed = false,
  }) {
    final value = Decimal.parse(raw).toStringAsFixed(2);
    final negative = value.startsWith('-');
    final digits = negative ? value.substring(1) : value;
    final parts = digits.split('.');
    final buffer = StringBuffer();
    final integer = parts[0];

    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) buffer.write(',');
      buffer.write(integer[i]);
    }

    final symbol = _symbols[currency] ?? '';
    final prefix = negative ? '-' : (signed ? '+' : '');
    final money = '$prefix${symbol.isEmpty ? '' : '$symbol '}$buffer.${parts[1]}';
    if (symbol.isEmpty && currency.isNotEmpty) return '$money $currency';
    return money;
  }

  /// Normaliza la entrada del usuario sin convertirla nunca a `double`.
  static String normalizeInput(String value, {int scale = 2}) {
    final parsed = Decimal.tryParse(value.trim());
    if (parsed == null) return value.trim();
    return parsed.toStringAsFixed(scale);
  }

  static String sum(Iterable<String> amounts) {
    return amounts.fold<Decimal>(
      Decimal.zero,
      (total, value) => total + Decimal.parse(value),
    ).toString();
  }
}
