import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/core/storage/secure_session_store.dart';
import 'package:mobile/core/theme/tenant_theme.dart';
import 'package:mobile/features/auth/data/auth_providers.dart';
import 'package:mobile/features/tenants/data/tenants_providers.dart';

import '../helpers/fake_adapter.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

AuthSession _session(
  String code,
  String color, {
  DateTime? issuedAt,
}) {
  final login = _fixture('login_response.json');
  final data = (login['data'] as Map).cast<String, dynamic>();
  final tenant = (data['tenant'] as Map).cast<String, dynamic>();
  return AuthSession.fromLogin(
    <String, dynamic>{
      ...data,
      'access_token': 'token-$code',
      'tenant': <String, dynamic>{
        ...tenant,
        'code': code,
        'name': 'Banco $code',
        'primary_color': color,
        'secondary_color': '#003087',
      },
    },
    issuedAt: issuedAt ?? DateTime.now(),
  );
}

void main() {
  late ProviderContainer container;
  late MemorySessionStorage storage;
  late RoutingFakeAdapter adapter;

  setUp(() {
    storage = MemorySessionStorage();
    adapter = RoutingFakeAdapter()
      ..routes[ApiEndpoints.tenants] = FakeResponse(
        200,
        <String, dynamic>{
          'success': true,
          'code': 'TENANTS_LISTED',
          'message': 'Instituciones disponibles',
          'data': <dynamic>[
            <String, dynamic>{
              'id': 't1',
              'code': 'BANCO_HORIZONTE',
              'name': 'Banco Horizonte',
              'status': 'ACTIVE',
              'primary_color': '#0070BA',
              'secondary_color': '#003087',
              'logo_url': null,
            },
            <String, dynamic>{
              'id': 't2',
              'code': 'BANCO_OTRO',
              'name': 'Banco Otro',
              'status': 'ACTIVE',
              'primary_color': '#123456',
              'secondary_color': '#654321',
              'logo_url': 'https://example.com/logo.png',
            },
          ],
          'correlation_id': 'corr-tenants',
        },
      );

    container = ProviderContainer(
      overrides: [
        secureSessionStoreProvider.overrideWithValue(
          SecureSessionStore(storage: storage),
        ),
        dioProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('mantiene tokens independientes y cambia sin re-login', () async {
    final store = container.read(secureSessionStoreProvider);
    final a = _session('BANCO_HORIZONTE', '#0070BA');
    final b = _session('BANCO_OTRO', '#123456');
    await store.saveSession(a);
    await store.saveSession(b);
    await store.setActiveTenant(a.tenant.code);

    await container.read(sessionControllerProvider.notifier).refresh();
    expect(container.read(sessionControllerProvider).value?.tenant.code,
        'BANCO_HORIZONTE');

    await container.read(sessionControllerProvider.notifier).switchTenant('BANCO_OTRO');

    expect(container.read(sessionControllerProvider).value?.accessToken,
        'token-BANCO_OTRO');
    expect(await container.read(authRepositoryProvider).activeTenantCode(),
        'BANCO_OTRO');
    expect((await store.readSession('BANCO_HORIZONTE'))?.accessToken,
        'token-BANCO_HORIZONTE');
  });

  test('el tema sigue al banco activo', () async {
    final store = container.read(secureSessionStoreProvider);
    await store.saveSession(_session('BANCO_HORIZONTE', '#0070BA'));
    await store.saveSession(_session('BANCO_OTRO', '#123456'));
    await container.read(sessionControllerProvider.notifier).refresh();

    expect(container.read(tenantThemeProvider).primary.toARGB32(), 0xFF0070BA);

    await container.read(sessionControllerProvider.notifier).switchTenant('BANCO_OTRO');
    expect(container.read(tenantThemeProvider).primary.toARGB32(), 0xFF123456);
  });

  test('un token vencido obliga a relogin solo de ese banco', () async {
    final store = container.read(secureSessionStoreProvider);
    await store.saveSession(
      _session('BANCO_HORIZONTE', '#0070BA',
          issuedAt: DateTime.now().subtract(const Duration(hours: 2))),
    );
    await store.saveSession(_session('BANCO_OTRO', '#123456'));
    await store.setActiveTenant('BANCO_HORIZONTE');

    await container.read(sessionControllerProvider.notifier).refresh();

    expect(container.read(sessionControllerProvider).value, isNull);
    expect(await store.getActiveTenant(), isNull);
    expect((await store.readSession('BANCO_OTRO'))?.accessToken,
        'token-BANCO_OTRO');
  });

  test('lista las instituciones del backend y las sesiones guardadas', () async {
    final store = container.read(secureSessionStoreProvider);
    final session = _session('BANCO_HORIZONTE', '#0070BA');
    await store.saveSession(session);
    // Fuerza AsyncData para evitar la race del FutureProvider en tests.
    await container.read(sessionControllerProvider.notifier).setSession(session);

    final tenants = await container.read(tenantsProvider.future);
    final sessions = await container.read(savedSessionsProvider.future);

    expect(tenants, hasLength(2));
    expect(tenants.last.logoUrl, 'https://example.com/logo.png');
    expect(sessions.single.tenant.code, 'BANCO_HORIZONTE');
  });

  test('parsea colores hexadecimales con o sin almohadilla', () {
    expect(TenantTheme.parseHex('#0070BA')?.toARGB32(), 0xFF0070BA);
    expect(TenantTheme.parseHex('123456')?.toARGB32(), 0xFF123456);
    expect(TenantTheme.parseHex('no-color'), isNull);
  });
}
