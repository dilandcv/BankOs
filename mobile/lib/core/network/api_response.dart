/// Sobre de respuesta estándar del backend:
/// `{ success, code, message, data, correlation_id }`.
class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.code,
    required this.message,
    required this.correlationId,
    this.data,
  });

  final bool success;
  final String code;
  final String message;
  final String correlationId;
  final T? data;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data)? parse,
  ) {
    final rawData = json['data'];
    T? parsedData;
    if (rawData != null) {
      parsedData = parse != null ? parse(rawData) : rawData as T;
    }

    return ApiEnvelope<T>(
      success: json['success'] as bool? ?? false,
      code: (json['code'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      correlationId: (json['correlation_id'] as String?) ?? '',
      data: parsedData,
    );
  }
}

/// Respuesta paginada usada por los listados del backend.
class PageResponse<T> {
  const PageResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<T> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic item) parse,
  ) {
    final rawItems = (json['items'] as List<dynamic>?) ?? const [];

    return PageResponse<T>(
      items: rawItems.map(parse).toList(growable: false),
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      totalElements: (json['total_elements'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
    );
  }
}
