import 'package:flutter/foundation.dart';

/// Configuración centralizada de la API.
///
/// La URL se puede sobrescribir en tiempo de compilación:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
class ApiConfig {
  const ApiConfig._();

  static const String apiPath = '/api/v1';
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl => '$_resolvedHost$apiPath';

  static String get _resolvedHost {
    if (_envBaseUrl.isNotEmpty) {
      return _withoutTrailingSlash(_envBaseUrl);
    }
    if (kIsWeb) return 'http://localhost:8080';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'http://localhost:8080';
      default:
        return 'http://10.0.2.2:8080';
    }
  }

  static String _withoutTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
