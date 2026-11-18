import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../session/auth_session.dart';

/// Abstracción mínima para poder probar el store sin plugins nativos.
abstract class SessionStorage {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String? value});
  Future<void> delete({required String key});
  Future<Map<String, String>> readAll();
  Future<void> deleteAll();
}

/// Implementación real sobre `flutter_secure_storage`.
class FlutterSecureSessionStorage implements SessionStorage {
  const FlutterSecureSessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<Map<String, String>> readAll() => _storage.readAll();

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

/// Guarda **un token por banco** y recuerda cuál está activo.
///
/// Claves: `bankos.session.<TENANT_CODE>` y `bankos.active_tenant`.
class SecureSessionStore {
  static const String sessionPrefix = 'bankos.session.';
  static const String activeTenantKey = 'bankos.active_tenant';
  static const String biometricPrefix = 'bankos.biometric.';

  SecureSessionStore({SessionStorage? storage})
      : _storage = storage ?? const FlutterSecureSessionStorage();

  final SessionStorage _storage;

  String sessionKey(String tenantCode) =>
      '$sessionPrefix${tenantCode.trim().toUpperCase()}';

  String biometricKey(String tenantCode) =>
      '$biometricPrefix${tenantCode.trim().toUpperCase()}';

  Future<void> saveSession(AuthSession session) async {
    final code = session.tenant.code.trim().toUpperCase();
    if (code.isEmpty) {
      throw ArgumentError.value(session.tenant.code, 'tenant.code', 'vacío');
    }
    if (session.accessToken.isEmpty) {
      throw ArgumentError.value(session.accessToken, 'accessToken', 'vacío');
    }
    await _storage.write(key: sessionKey(code), value: session.serialize());
  }

  Future<AuthSession?> readSession(String tenantCode) async {
    final key = sessionKey(tenantCode);
    final raw = await _storage.read(key: key);
    if (raw == null || raw.isEmpty) return null;

    try {
      return AuthSession.deserialize(raw);
    } catch (_) {
      // Un registro corrupto no debe bloquear el login de ese banco.
      await _storage.delete(key: key);
      return null;
    }
  }

  Future<List<String>> tenantCodes() async {
    final all = await _storage.readAll();
    final codes = all.keys
        .where((key) => key.startsWith(sessionPrefix))
        .map((key) => key.substring(sessionPrefix.length))
        .toList();
    codes.sort();
    return codes;
  }

  Future<String?> getActiveTenant() async {
    final value = await _storage.read(key: activeTenantKey);
    if (value == null || value.isEmpty) return null;
    return value.trim().toUpperCase();
  }

  Future<void> setActiveTenant(String tenantCode) async {
    final code = tenantCode.trim().toUpperCase();
    if (code.isEmpty) {
      await clearActiveTenant();
      return;
    }
    await _storage.write(key: activeTenantKey, value: code);
  }

  Future<void> clearActiveTenant() => _storage.delete(key: activeTenantKey);

  Future<AuthSession?> readActiveSession() async {
    final code = await getActiveTenant();
    if (code == null) return null;
    return readSession(code);
  }

  Future<void> removeSession(String tenantCode) async {
    final code = tenantCode.trim().toUpperCase();
    await _storage.delete(key: sessionKey(code));
    await _storage.delete(key: biometricKey(code));
    final active = await getActiveTenant();
    if (active == code) await clearActiveTenant();
  }

  Future<void> clearAll() async {
    final all = await _storage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(sessionPrefix) ||
          key.startsWith(biometricPrefix) ||
          key == activeTenantKey) {
        await _storage.delete(key: key);
      }
    }
  }

  Future<bool> isBiometricEnabled(String tenantCode) async {
    final value = await _storage.read(key: biometricKey(tenantCode));
    return value == '1';
  }

  Future<void> setBiometricEnabled(String tenantCode, bool enabled) async {
    final key = biometricKey(tenantCode);
    if (enabled) {
      await _storage.write(key: key, value: '1');
    } else {
      await _storage.delete(key: key);
    }
  }
}
