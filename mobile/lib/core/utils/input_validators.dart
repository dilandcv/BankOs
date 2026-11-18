import '../network/api_exception.dart';

/// Validaciones de entrada para evitar que un UUID malformado llegue al
/// backend y provoque un 500 difícil de diagnosticar.
class InputValidators {
  /// Acepta UUID canónicos incluidos los del seed (`30000000-0000-...`).
  static final RegExp uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool isUuid(String value) => uuidPattern.hasMatch(value.trim());

  static String requireUuid(String value, {String field = 'id'}) {
    if (!isUuid(value)) {
      throw ApiException(
        code: 'INVALID_ID',
        message: 'El $field no es válido',
        fieldErrors: <String, String>{field: 'Identificador malformado'},
      );
    }
    return value.trim();
  }

  static String requireText(String value, {String field = 'valor'}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ApiException(
        code: 'VALIDATION_ERROR',
        message: 'El $field es obligatorio',
        fieldErrors: <String, String>{field: 'Campo obligatorio'},
      );
    }
    return trimmed;
  }
}
