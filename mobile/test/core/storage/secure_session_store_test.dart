import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
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

AuthSession _session(String code, String token) {
  final login = jsonDecode(File('test/fixtures/login_response.json').readAsStringSync())
      as Map<String, dynamic>;
  final data = (login['data'] as Map).cast<String, dynamic>();
  final tenant = (data['tenant'] as Map).cast<String, dynamic>();
  return AuthSession.fromLogin(
    <String, dynamic>{
      ...data,
      'access_token': token,
      'tenant': <String, dynamic>{...tenant, 'code': code},
    },
    issuedAt: DateTime.parse('2026-11-17T12:00:00Z'),
  );
}

void main() {
  late _MemoryStorage storage;
  late SecureSessionStore store;

  setUp(() {
    storage = _MemoryStorage();
    store = SecureSessionStore(storage: storage);
  });

  test('guarda un token por banco y mantiene el activo', () async {
    await store.saveSession(_session('BANCO_HORIZONTE', 'token-a'));
    await store.saveSession(_session('BANCO_OTRO', 'token-b'));
    await store.setActiveTenant('banco_otro');

    expect(storage.values.keys, contains('bankos.session.BANCO_HORIZONTE'));
    expect(storage.values.keys, contains('bankos.session.BANCO_OTRO'));
    expect(await store.getActiveTenant(), 'BANCO_OTRO');
    expect((await store.readActiveSession())?.accessToken, 'token-b');
    expect((await store.readSession('BANCO_HORIZONTE'))?.accessToken, 'token-a');
    expect(await store.tenantCodes(), ['BANCO_HORIZONTE', 'BANCO_OTRO']);
  });

  test('cambiar de banco no invalida la otra sesión', () async {
    await store.saveSession(_session('A', 'token-a'));
    await store.saveSession(_session('B', 'token-b'));
    await store.setActiveTenant('A');

    await store.setActiveTenant('B');

    expect((await store.readActiveSession())?.accessToken, 'token-b');
    expect((await store.readSession('A'))?.accessToken, 'token-a');
  });

  test('logout de un banco solo limpia su token', () async {
    await store.saveSession(_session('A', 'token-a'));
    await store.saveSession(_session('B', 'token-b'));
    await store.setActiveTenant('A');

    await store.removeSession('A');

    expect(await store.getActiveTenant(), isNull);
    expect(await store.readSession('A'), isNull);
    expect(await store.readSession('B'), isNotNull);
  });

  test('descarta registros corruptos sin afectar a otros bancos', () async {
    await store.saveSession(_session('A', 'token-a'));
    await storage.write(key: 'bankos.session.B', value: '{no-json');

    expect(await store.readSession('B'), isNull);
    expect(storage.values, isNot(contains('bankos.session.B')));
    expect((await store.readSession('A'))?.accessToken, 'token-a');
  });

  test('biometría se guarda por banco', () async {
    expect(await store.isBiometricEnabled('A'), isFalse);
    await store.setBiometricEnabled('A', true);
    expect(await store.isBiometricEnabled('A'), isTrue);
    expect(await store.isBiometricEnabled('B'), isFalse);
  });
}
