import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/storage/secure_session_store.dart';
import 'package:mobile/features/audit/data/audit_providers.dart';
import 'package:mobile/features/customers/data/customers_providers.dart';
import 'package:mobile/features/settings/data/settings_providers.dart';
import 'package:mobile/features/tenants/data/tenants_providers.dart';
import 'package:mobile/features/transactions/data/transactions_providers.dart';
import 'package:mobile/features/users/data/users_providers.dart';
import 'package:mobile/features/webhooks/data/webhooks_providers.dart';

import '../helpers/fake_adapter.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _ok(String code, dynamic data) => <String, dynamic>{
      'success': true,
      'code': code,
      'message': 'Operación correcta',
      'data': data,
      'correlation_id': 'test-correlation',
    };

Map<String, dynamic> _forbidden() => <String, dynamic>{
      'success': false,
      'code': 'FORBIDDEN',
      'message': 'Acceso denegado para tu rol',
      'data': null,
      'correlation_id': 'test-correlation',
    };

void main() {
  late ProviderContainer container;
  late RoutingFakeAdapter adapter;
  late MemorySessionStorage storage;

  setUp(() async {
    storage = MemorySessionStorage();
    adapter = RoutingFakeAdapter()
      ..routes[ApiEndpoints.authLogin] =
          FakeResponse(200, _fixture('login_response.json'));

    container = ProviderContainer(
      overrides: [
        secureSessionStoreProvider.overrideWithValue(
          SecureSessionStore(storage: storage),
        ),
        dioProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
      ],
    );

    final session = await container.read(authRepositoryProvider).login(
          tenantCode: 'BANCO_HORIZONTE',
          email: 'admin@horizonte.com',
          password: 'Admin123!',
        );
    await container.read(sessionControllerProvider.notifier).setSession(session);
    adapter.requests.clear();
  });

  tearDown(() => container.dispose());

  group('detalle de transacción', () {
    const detailId = '40000000-0000-0000-0000-000000000001';

    test('GET /transactions/{id} devuelve el movimiento con sus asientos', () async {
      adapter.routes[ApiEndpoints.transactionById(detailId)] = FakeResponse(
        200,
        _ok('TRANSACTION_FOUND', <String, dynamic>{
          'id': detailId,
          'type': 'TRANSFER',
          'status': 'COMPLETED',
          'amount': '100.0000',
          'currency': 'USD',
          'fee': '1.5000',
          'exchange_rate': '0.92000000',
          'source_account_id': '30000000-0000-0000-0000-000000000001',
          'destination_account_id': '30000000-0000-0000-0000-000000000003',
          'description': 'Transferencia de prueba',
          'correlation_id': 'corr-detalle',
          'created_at': '2026-11-17T14:00:00Z',
          'entries': <dynamic>[
            <String, dynamic>{
              'id': '60000000-0000-0000-0000-000000000001',
              'account_id': '30000000-0000-0000-0000-000000000001',
              'direction': 'DEBIT',
              'amount': '101.5000',
              'currency': 'USD',
              'created_at': '2026-11-17T14:00:00Z',
            },
          ],
        }),
      );

      final detail =
          await container.read(transactionByIdProvider(detailId).future);

      expect(detail.id, detailId);
      expect(detail.type, 'TRANSFER');
      expect(detail.amount, '100.0000');
      expect(detail.entries, hasLength(1));
      expect(detail.entries.first.isCredit, isFalse);
      expect(
        adapter.requests.single.options.path,
        ApiEndpoints.transactionById(detailId),
      );
    });

    test('un id malformado se rechaza en cliente antes de llamar al backend',
        () async {
      await expectLater(
        container.read(transactionByIdProvider('no-es-un-uuid').future),
        throwsA(isA<ApiException>()),
      );
      expect(adapter.requests, isEmpty);
    });
  });

  group('repositorios admin', () {
    test('crear usuario envía snake_case y normaliza correo/rol', () async {
      adapter.routes[ApiEndpoints.users] = FakeResponse(
        200,
        _ok('USER_CREATED', <String, dynamic>{
          'id': '70000000-0000-0000-0000-000000000001',
          'email': 'nuevo@horizonte.com',
          'full_name': 'Nuevo Usuario',
          'role': 'OPERATOR',
          'status': 'ACTIVE',
          'created_at': '2026-11-17T14:00:00Z',
        }),
      );

      final created = await container.read(usersRepositoryProvider).create(
            email: '  NUEVO@horizonte.com  ',
            fullName: '  Nuevo Usuario  ',
            password: 'Password123!',
            role: 'operator',
          );

      expect(created.role, 'OPERATOR');
      expect(created.isActive, isTrue);
      final sent = adapter.requests.single;
      expect(sent.options.method, 'POST');
      expect(sent.decodedBody!['email'], 'nuevo@horizonte.com');
      expect(sent.decodedBody!['full_name'], 'Nuevo Usuario');
      expect(sent.decodedBody!['role'], 'OPERATOR');
    });

    test('crear cliente envía tipo de documento en mayúsculas', () async {
      adapter.routes[ApiEndpoints.customers] = FakeResponse(
        200,
        _ok('CUSTOMER_CREATED', <String, dynamic>{
          'id': '80000000-0000-0000-0000-000000000001',
          'document_type': 'CC',
          'document_number': '123456789',
          'full_name': 'Cliente Prueba',
          'status': 'ACTIVE',
          'created_at': '2026-11-17T14:00:00Z',
        }),
      );

      final created = await container.read(customersRepositoryProvider).create(
            documentType: 'cc',
            documentNumber: '123456789',
            fullName: 'Cliente Prueba',
          );

      expect(created.documentType, 'CC');
      expect(adapter.requests.single.decodedBody!['document_type'], 'CC');
    });

    test('actualizar configuración usa PUT y el mapa de settings', () async {
      adapter.routes[ApiEndpoints.settings] = FakeResponse(
        200,
        _ok('SETTINGS_UPDATED', <String, dynamic>{
          'settings': <String, dynamic>{
            'transfer.fee.fixed': '1.50',
            'transfer.fee.percent': '0.75',
          },
        }),
      );

      final settings =
          await container.read(settingsRepositoryProvider).updateSettings(
                <String, String>{
                  'transfer.fee.fixed': '1.50',
                  'transfer.fee.percent': '0.75',
                },
              );

      expect(settings.feeFixed, '1.50');
      expect(settings.feePercentDecimal().toString(), '0.75');
      final sent = adapter.requests.single;
      expect(sent.options.method, 'PUT');
      expect(
        (sent.decodedBody!['settings'] as Map)['transfer.fee.fixed'],
        '1.50',
      );
    });

    test('crear tasa de cambio envía effective_to nulo cuando se omite', () async {
      adapter.routes[ApiEndpoints.exchangeRates] = FakeResponse(
        200,
        _ok('RATE_CREATED', <String, dynamic>{
          'id': '90000000-0000-0000-0000-000000000001',
          'from_currency': 'USD',
          'to_currency': 'EUR',
          'rate': '0.92000000',
          'effective_from': '2026-11-17T00:00:00Z',
          'effective_to': null,
          'active': true,
          'created_at': '2026-11-17T14:00:00Z',
        }),
      );

      final rate = await container.read(settingsRepositoryProvider).createRate(
            fromCurrency: 'usd',
            toCurrency: 'eur',
            rate: '0.92000000',
            effectiveFrom: '2026-11-17T00:00:00Z',
          );

      expect(rate.pair, 'USD → EUR');
      final sent = adapter.requests.single.decodedBody!;
      expect(sent['from_currency'], 'USD');
      expect(sent['effective_to'], isNull);
    });

    test('consultar auditoría por id usa el endpoint con UUID', () async {
      const auditId = 'a0000000-0000-0000-0000-000000000001';
      const transactionId = '40000000-0000-0000-0000-000000000001';
      adapter.routes[ApiEndpoints.auditLogById(auditId)] = FakeResponse(
        200,
        _ok('AUDIT_FOUND', <String, dynamic>{
          'id': auditId,
          'actor_user_id': '70000000-0000-0000-0000-000000000001',
          'action': 'TRANSACTION_CREATED',
          'resource_type': 'TRANSACTION',
          'resource_id': transactionId,
          'metadata': '{}',
          'correlation_id': 'corr-audit',
          'created_at': '2026-11-17T14:00:00Z',
        }),
      );

      final log = await container.read(auditRepositoryProvider).byId(auditId);

      expect(log.action, 'TRANSACTION_CREATED');
      expect(adapter.requests.single.options.path,
          ApiEndpoints.auditLogById(auditId));
    });

    test('crear webhook envía el secreto y la respuesta no lo devuelve', () async {
      adapter.routes[ApiEndpoints.webhooks] = FakeResponse(
        200,
        _ok('WEBHOOK_CREATED', <String, dynamic>{
          'id': 'b0000000-0000-0000-0000-000000000001',
          'url': 'https://example.com/hook',
          'events': 'transaction.completed',
          'status': 'ACTIVE',
          'created_at': '2026-11-17T14:00:00Z',
        }),
      );

      final hook = await container.read(webhooksRepositoryProvider).create(
            url: 'https://example.com/hook',
            events: 'transaction.completed',
            secret: 'super-secreto-12345',
          );

      expect(hook.url, 'https://example.com/hook');
      final sent = adapter.requests.single.decodedBody!;
      expect(sent['secret'], 'super-secreto-12345');
      expect(sent.containsKey('secret'), isTrue);
    });

    test('crear institución normaliza el código y mapea los colores', () async {
      adapter.routes[ApiEndpoints.tenants] = FakeResponse(
        200,
        _ok('TENANT_CREATED', <String, dynamic>{
          'id': 'c0000000-0000-0000-0000-000000000001',
          'code': 'BANCO_NUEVO',
          'name': 'Banco Nuevo',
          'primary_color': '#0070BA',
          'secondary_color': '#003087',
          'logo_url': null,
          'status': 'ACTIVE',
          'created_at': '2026-11-17T14:00:00Z',
        }),
      );

      final tenant = await container.read(tenantsRepositoryProvider).create(
            code: 'banco_nuevo',
            name: 'Banco Nuevo',
            primaryColor: '#0070BA',
            secondaryColor: '#003087',
          );

      expect(tenant.code, 'BANCO_NUEVO');
      expect(tenant.isActive, isTrue);
      final sent = adapter.requests.single.decodedBody!;
      expect(sent['code'], 'BANCO_NUEVO');
      expect(sent['primary_color'], '#0070BA');
      expect(sent['logo_url'], isNull);
    });
  });

  group('manejo de 403', () {
    test('un FORBIDDEN del backend se convierte en ApiException.isForbidden',
        () async {
      adapter.routes[ApiEndpoints.users] =
          FakeResponse(403, _forbidden());

      await expectLater(
        container.read(usersRepositoryProvider).list(),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 403)
              .having((error) => error.isForbidden, 'isForbidden', isTrue)
              .having(
                (error) => error.displayMessage,
                'displayMessage',
                'Acceso denegado para tu rol',
              ),
        ),
      );
    });

    test('el listado de instituciones degrade a vacío ante 403', () async {
      adapter.routes[ApiEndpoints.tenants] =
          FakeResponse(403, _forbidden());

      final tenants = await container.read(tenantsProvider.future);
      expect(tenants, isEmpty);
    });
  });
}
