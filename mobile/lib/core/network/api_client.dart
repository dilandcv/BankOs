import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../storage/secure_session_store.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'api_response.dart';

/// Envía el `X-Correlation-ID` en cada petición para poder rastrearla en logs.
class CorrelationInterceptor extends Interceptor {
  CorrelationInterceptor({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('X-Correlation-ID', () => _uuid.v4());
    handler.next(options);
  }
}

/// Garantiza un `Idempotency-Key` estable por operación financiera.
///
/// Si el repositorio envía una llave explícita, se respeta. Si no, se genera
/// una y se reutiliza mientras la huella (método + ruta + body) sea la misma.
class IdempotencyInterceptor extends Interceptor {
  static const Set<String> _financialPaths = <String>{
    ApiEndpoints.deposits,
    ApiEndpoints.withdrawals,
    ApiEndpoints.transfers,
  };

  IdempotencyInterceptor({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  final Map<String, String> _keysByFingerprint = <String, String>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'POST' && _isFinancial(options.path)) {
      final fingerprint = _fingerprint(options);
      final explicit = options.headers['Idempotency-Key'] as String?;
      final key = explicit ??
          _keysByFingerprint.putIfAbsent(fingerprint, () => _uuid.v4());

      options.headers['Idempotency-Key'] = key;
      _keysByFingerprint[fingerprint] = key;
    }
    handler.next(options);
  }

  bool _isFinancial(String path) {
    final clean = path.split('?').first;
    return _financialPaths.contains(clean);
  }

  String _fingerprint(RequestOptions options) => jsonEncode(<String, dynamic>{
        'method': options.method.toUpperCase(),
        'path': options.path,
        'query': options.queryParameters,
        'body': options.data,
      });

  /// Llama al iniciar una operación **nueva** que debe tener otra llave.
  void reset() => _keysByFingerprint.clear();
}

/// Adjunta el JWT del banco activo, excepto en `/auth/login`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._store);

  final SecureSessionStore _store;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path == ApiEndpoints.authLogin) {
      handler.next(options);
      return;
    }

    final path = options.path;
    final isPlatformPath = path.startsWith('/banks') ||
        path.startsWith('/user/banks') ||
        path == ApiEndpoints.authExchangeBankToken;

    if (isPlatformPath) {
      final masterSession = await _store.readMasterSession();
      if (masterSession != null &&
          masterSession.accessToken.isNotEmpty &&
          !masterSession.isExpired()) {
        options.headers['Authorization'] =
            'Bearer ${masterSession.accessToken}';
        handler.next(options);
        return;
      }
    }

    final session = await _store.readActiveSession();
    if (session != null &&
        session.accessToken.isNotEmpty &&
        !session.isExpired()) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    } else {
      final masterSession = await _store.readMasterSession();
      if (masterSession != null &&
          masterSession.accessToken.isNotEmpty &&
          !masterSession.isExpired()) {
        options.headers['Authorization'] =
            'Bearer ${masterSession.accessToken}';
      }
    }
    handler.next(options);
  }
}

/// Normaliza cualquier fallo de Dio a [ApiException].
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor({this._onUnauthorized});

  final void Function()? _onUnauthorized;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final isLogin = err.requestOptions.path == ApiEndpoints.authLogin;

    if (statusCode == 401 && !isLogin) {
      _onUnauthorized?.call();
    }

    if (err.error is ApiException) {
      handler.reject(err);
      return;
    }

    final data = err.response?.data;
    final ApiException exception;
    if (data is Map) {
      exception = ApiException.fromEnvelope(
        Map<String, dynamic>.from(data),
        statusCode: statusCode,
      );
    } else {
      final message = err.message ?? '';
      exception = ApiException.network(
        message.isEmpty ? 'Error de red' : message,
        statusCode: statusCode,
      );
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }
}

/// Cliente HTTP único de la app. Ningún widget llama a Dio directamente.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required SecureSessionStore sessionStore,
    Dio? dio,
    Uuid? uuid,
  })  : idempotency = IdempotencyInterceptor(uuid: uuid),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: <String, dynamic>{
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.addAll(<Interceptor>[
      CorrelationInterceptor(uuid: uuid),
      idempotency,
      AuthInterceptor(sessionStore),
      ErrorInterceptor(onUnauthorized: sessionStore.clearActiveTenant),
    ]);
  }

  final Dio _dio;
  final IdempotencyInterceptor idempotency;

  Dio get dio => _dio;

  Future<ApiEnvelope<T>> request<T>(
    String path, {
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? parse,
  }) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.request<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method.toUpperCase(),
          headers: headers,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );
    } on DioException catch (error) {
      // Los repositorios solo deben manejar ApiException, nunca DioException.
      final normalized = error.error;
      if (normalized is ApiException) throw normalized;
      rethrow;
    }

    return _parseEnvelope<T>(response, parse);
  }

  Future<ApiEnvelope<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? parse,
  }) {
    return request<T>(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      headers: headers,
      parse: parse,
    );
  }

  Future<ApiEnvelope<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? parse,
  }) {
    return request<T>(
      path,
      method: 'POST',
      data: data,
      headers: headers,
      parse: parse,
    );
  }

  Future<ApiEnvelope<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? parse,
  }) {
    return request<T>(
      path,
      method: 'PUT',
      data: data,
      headers: headers,
      parse: parse,
    );
  }

  Future<ApiEnvelope<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? parse,
  }) {
    return request<T>(
      path,
      method: 'PATCH',
      data: data,
      headers: headers,
      parse: parse,
    );
  }

  Future<ApiEnvelope<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic data)? parse,
  }) {
    return request<T>(
      path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      parse: parse,
    );
  }

  ApiEnvelope<T> _parseEnvelope<T>(
    Response<Map<String, dynamic>> response,
    T Function(dynamic data)? parse,
  ) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ApiException.network(
        'Respuesta inesperada del servidor',
        statusCode: response.statusCode,
      );
    }

    final envelope = ApiEnvelope<T>.fromJson(body, parse);
    if (!envelope.success) {
      throw ApiException.fromEnvelope(body, statusCode: response.statusCode);
    }
    return envelope;
  }

  void forgetIdempotencyKeys() => idempotency.reset();
}
