import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/core/storage/secure_session_store.dart';

class _MemoryStorage implements SessionStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({required String key}) async => values.remove(key);

  @override
  Future<Map<String, String>> readAll() async => Map.unmodifiable(values);

  @override
  Future<void> deleteAll() async => values.clear();
}

class _RecordedRequest {
  _RecordedRequest(this.options, this.body);

  final RequestOptions options;
  final String? body;
}

class _FakeAdapter implements HttpClientAdapter {
  final List<_RecordedRequest> requests = <_RecordedRequest>[];
  Map<String, dynamic> response = <String, dynamic>{
    'success': true,
    'code': 'OK',
    'message': 'ok',
    'data': <String, dynamic>{},
    'correlation_id': 'server-corr',
  };
  int statusCode = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Uint8List? bytes;
    if (requestStream != null) {
      bytes = await requestStream.fold<Uint8List>(
        Uint8List(0),
        (previous, element) => Uint8List.fromList(<int>[...previous, ...element]),
      );
    }
    requests.add(_RecordedRequest(options, bytes == null ? null : utf8.decode(bytes)));

    return ResponseBody.fromString(
      jsonEncode(response),
      statusCode,
      headers: <String, List<String>>{
        'content-type': <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

AuthSession _session() {
  return AuthSession.fromLogin(
    <String, dynamic>{
      'access_token': 'token-real',
      'token_type': 'Bearer',
      'expires_in': 3600,
      'user': <String, dynamic>{
        'id': 'u1',
        'email': 'admin@horizonte.com',
        'full_name': 'Admin',
        'role': 'TENANT_ADMIN',
      },
      'tenant': <String, dynamic>{
        'id': 't1',
        'code': 'BANCO_HORIZONTE',
        'name': 'Banco Horizonte',
        'primary_color': '#0070BA',
        'secondary_color': '#003087',
      },
    },
    issuedAt: DateTime.now(),
  );
}

void main() {
  late _MemoryStorage storage;
  late SecureSessionStore store;
  late _FakeAdapter adapter;
  late ApiClient api;

  setUp(() async {
    storage = _MemoryStorage();
    store = SecureSessionStore(storage: storage);
    await store.saveSession(_session());
    await store.setActiveTenant('BANCO_HORIZONTE');

    adapter = _FakeAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    api = ApiClient(baseUrl: 'http://localhost:8080/api/v1', sessionStore: store, dio: dio);
  });

  test('login no envía Bearer ni Idempotency-Key pero sí correlation id', () async {
    await api.post<dynamic>(
      ApiEndpoints.authLogin,
      data: <String, dynamic>{'tenant_code': 'BANCO_HORIZONTE'},
    );

    final sent = adapter.requests.single.options;
    expect(sent.headers['Authorization'], isNull);
    expect(sent.headers['Idempotency-Key'], isNull);
    expect(sent.headers['X-Correlation-ID'], isNotEmpty);
  });

  test('las rutas protegidas envían el Bearer del banco activo', () async {
    await api.get<dynamic>(ApiEndpoints.authMe);

    final sent = adapter.requests.single.options;
    expect(sent.headers['Authorization'], 'Bearer token-real');
    expect(sent.headers['X-Correlation-ID'], isNotEmpty);
  });

  test('reutiliza la misma llave para el mismo depósito y otra para otro body', () async {
    final body = <String, dynamic>{
      'account_id': 'acc-1',
      'amount': '50.00',
      'currency': 'USD',
    };

    await api.post<dynamic>(ApiEndpoints.deposits, data: body);
    await api.post<dynamic>(ApiEndpoints.deposits, data: body);
    await api.post<dynamic>(
      ApiEndpoints.deposits,
      data: <String, dynamic>{...body, 'amount': '60.00'},
    );

    final keys = adapter.requests
        .map((request) => request.options.headers['Idempotency-Key'] as String)
        .toList();

    expect(keys[0], isNotEmpty);
    expect(keys[0], keys[1]);
    expect(keys[2], isNot(keys[0]));
  });

  test('respeta una llave explícita y permite empezar una operación nueva', () async {
    await api.post<dynamic>(
      ApiEndpoints.transfers,
      data: <String, dynamic>{'amount': '10.00'},
      headers: <String, dynamic>{'Idempotency-Key': 'llave-del-repositorio'},
    );

    expect(
      adapter.requests.single.options.headers['Idempotency-Key'],
      'llave-del-repositorio',
    );

    api.forgetIdempotencyKeys();
    await api.post<dynamic>(
      ApiEndpoints.transfers,
      data: <String, dynamic>{'amount': '10.00'},
    );

    expect(
      adapter.requests.last.options.headers['Idempotency-Key'],
      isNot('llave-del-repositorio'),
    );
  });

  test('convierte errores de validación a ApiException', () async {
    adapter
      ..statusCode = 400
      ..response = <String, dynamic>{
        'success': false,
        'code': 'VALIDATION_ERROR',
        'message': 'Datos de entrada inválidos',
        'data': <String, dynamic>{'accountId': 'must not be null'},
        'correlation_id': 'corr-error',
      };

    expect(
      () => api.post<dynamic>(ApiEndpoints.deposits, data: <String, dynamic>{}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', 'VALIDATION_ERROR')
            .having((e) => e.isValidation, 'isValidation', isTrue)
            .having((e) => e.fieldErrors['accountId'], 'field', 'must not be null'),
      ),
    );
  });

  test('un 401 limpia el banco activo para obligar a relogin', () async {
    adapter
      ..statusCode = 401
      ..response = <String, dynamic>{
        'success': false,
        'code': 'UNAUTHORIZED',
        'message': 'Token expirado',
        'data': null,
        'correlation_id': 'corr-401',
      };

    await expectLater(
      api.get<dynamic>(ApiEndpoints.authMe),
      throwsA(
        isA<ApiException>().having((e) => e.isUnauthorized, '401', isTrue),
      ),
    );

    expect(await store.getActiveTenant(), isNull);
  });
}
