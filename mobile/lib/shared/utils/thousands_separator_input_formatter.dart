import 'package:flutter/services.dart';

/// Formateador de texto en tiempo real para campos monetarios.
///
/// Agrega automáticamente separadores de miles (,) en la parte entera
/// y permite hasta dos dígitos decimales precedidos por punto (.).
///
/// Si el usuario presiona una coma en teclados numéricos hispanos,
/// se interpreta de manera amigable como el separador decimal (.).
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter({this.maxDecimalDigits = 2});

  final int maxDecimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text;

    // Si el usuario escribió una coma manualmente (común en teclados hispanos)
    // y aún no hay punto decimal, la convertimos a punto (.)
    if (newValue.text.length > oldValue.text.length) {
      final insertIndex = newValue.selection.baseOffset - 1;
      if (insertIndex >= 0 && insertIndex < newValue.text.length) {
        final insertedChar = newValue.text[insertIndex];
        if (insertedChar == ',' && !oldValue.text.contains('.')) {
          text = '${text.substring(0, insertIndex)}.${text.substring(insertIndex + 1)}';
        }
      }
    }

    // Contar cuántos caracteres no-coma había antes del cursor en el texto nuevo
    int charsBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.baseOffset && i < text.length; i++) {
      if (text[i] != ',') {
        charsBeforeCursor++;
      }
    }

    final hasDot = text.contains('.');
    final parts = text.split('.');
    final rawInt = parts[0].replaceAll(',', '');
    final rawDec = parts.length > 1
        ? parts.sublist(1).join('').replaceAll(',', '')
        : null;

    // Limpiar dígitos
    String cleanInt = rawInt.replaceAll(RegExp(r'\D'), '');
    String? cleanDec;
    if (rawDec != null) {
      final filteredDec = rawDec.replaceAll(RegExp(r'\D'), '');
      cleanDec = filteredDec.length > maxDecimalDigits
          ? filteredDec.substring(0, maxDecimalDigits)
          : filteredDec;
    }

    if (cleanInt.isEmpty && cleanDec == null && !hasDot) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Formatear la parte entera con separadores de miles
    String formattedInt;
    if (cleanInt.isNotEmpty) {
      if (cleanInt.length > 1 && cleanInt.startsWith('0')) {
        cleanInt = BigInt.parse(cleanInt).toString();
      }
      final buffer = StringBuffer();
      for (int i = 0; i < cleanInt.length; i++) {
        if (i > 0 && (cleanInt.length - i) % 3 == 0) {
          buffer.write(',');
        }
        buffer.write(cleanInt[i]);
      }
      formattedInt = buffer.toString();
    } else {
      formattedInt = hasDot ? '0' : '';
    }

    // Construir la cadena formateada
    final String formatted;
    if (hasDot) {
      formatted = '$formattedInt.${cleanDec ?? ''}';
    } else {
      formatted = formattedInt;
    }

    // Recalcular posición del cursor conservando la posición relativa
    int newCursor = formatted.length;
    int seenChars = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (seenChars == charsBeforeCursor) {
        newCursor = i;
        break;
      }
      if (formatted[i] != ',') {
        seenChars++;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }
}
