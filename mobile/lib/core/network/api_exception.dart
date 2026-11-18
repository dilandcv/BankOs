/// Error normalizado del backend o de la capa de red.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.correlationId,
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String code;
  final String message;
  final String? correlationId;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  factory ApiException.fromEnvelope(
    Map<String, dynamic> body, {
    int? statusCode,
  }) {
    final rawFieldErrors = body['data'];
    final fieldErrors = <String, String>{};
    if (rawFieldErrors is Map) {
      rawFieldErrors.forEach((key, value) {
        fieldErrors[key.toString()] = value.toString();
      });
    }

    return ApiException(
      code: (body['code'] as String?) ?? 'INTERNAL_ERROR',
      message: (body['message'] as String?) ?? 'Error inesperado',
      correlationId: body['correlation_id'] as String?,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
    );
  }

  factory ApiException.network(String message, {int? statusCode}) {
    return ApiException(
      code: 'NETWORK_ERROR',
      message: message,
      statusCode: statusCode,
    );
  }

  bool get isUnauthorized =>
      statusCode == 401 || code == 'UNAUTHORIZED' || code == 'INVALID_CREDENTIALS';

  bool get isForbidden => statusCode == 403 || code == 'FORBIDDEN';

  bool get isValidation =>
      statusCode == 400 || code == 'VALIDATION_ERROR' || fieldErrors.isNotEmpty;

  String get displayMessage {
    if (fieldErrors.isEmpty) return message;
    final first = fieldErrors.entries.first;
    return '${first.key}: ${first.value}';
  }

  @override
  String toString() =>
      'ApiException(code: $code, message: $message, status: $statusCode, '
      'correlation_id: $correlationId)';
}
