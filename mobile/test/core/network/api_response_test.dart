import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/network/api_response.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('ApiEnvelope', () {
    test('conserva el sobre real del login', () {
      final envelope = ApiEnvelope<Map<String, dynamic>>.fromJson(
        _fixture('login_response.json'),
        (data) => (data as Map).cast<String, dynamic>(),
      );

      expect(envelope.success, isTrue);
      expect(envelope.code, 'LOGIN_SUCCESS');
      expect(envelope.message, 'Sesión iniciada correctamente');
      expect(envelope.correlationId, isNotEmpty);
      expect(envelope.data?['token_type'], 'Bearer');
      expect(envelope.data?['expires_in'], 3600);
    });

    test('parsea una respuesta paginada vacía', () {
      final envelope = ApiEnvelope<Map<String, dynamic>>.fromJson(
        _fixture('transactions_empty_response.json'),
        (data) => (data as Map).cast<String, dynamic>(),
      );

      final page = PageResponse<Map<String, dynamic>>.fromJson(
        envelope.data!,
        (item) => (item as Map).cast<String, dynamic>(),
      );

      expect(page.items, isEmpty);
      expect(page.page, 0);
      expect(page.size, 5);
      expect(page.totalElements, 0);
      expect(page.totalPages, 0);
    });
  });

  group('ApiException', () {
    test('extrae errores de validación en camelCase', () {
      final exception = ApiException.fromEnvelope(
        <String, dynamic>{
          'success': false,
          'code': 'VALIDATION_ERROR',
          'message': 'Datos de entrada inválidos',
          'data': <String, dynamic>{
            'accountId': 'must not be null',
            'sourceAccountId': 'must not be blank',
          },
          'correlation_id': 'corr-1',
        },
        statusCode: 400,
      );

      expect(exception.isValidation, isTrue);
      expect(exception.statusCode, 400);
      expect(exception.correlationId, 'corr-1');
      expect(exception.fieldErrors['accountId'], 'must not be null');
      expect(exception.displayMessage, contains('accountId'));
    });

    test('clasifica 401/403 y errores de red', () {
      final unauthorized = ApiException.fromEnvelope(
        <String, dynamic>{'code': 'UNAUTHORIZED', 'message': 'Token inválido'},
        statusCode: 401,
      );
      final forbidden = ApiException.network('Sin permisos', statusCode: 403);

      expect(unauthorized.isUnauthorized, isTrue);
      expect(unauthorized.isForbidden, isFalse);
      expect(forbidden.isForbidden, isTrue);
      expect(forbidden.code, 'NETWORK_ERROR');
    });
  });
}
