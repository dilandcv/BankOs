import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/core/storage/secure_session_store.dart';

/// Identidad vigente según `/auth/me`.
class CurrentIdentity {
  const CurrentIdentity({required this.user, required this.tenant});

  final UserSummary user;
  final TenantSummary tenant;
}

/// Única puerta de entrada a autenticación y sesiones multi-banco.
class AuthRepository {
  AuthRepository(this._api, this._store);

  final ApiClient _api;
  final SecureSessionStore _store;

  Future<AuthSession> login({
    required String tenantCode,
    required String email,
    required String password,
  }) async {
    final envelope = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: <String, dynamic>{
        'tenant_code': tenantCode.trim().toUpperCase(),
        'email': email.trim(),
        'password': password,
      },
      parse: (raw) => (raw as Map).cast<String, dynamic>(),
    );

    final data = envelope.data;
    if (data == null) {
      throw ApiException.network('El servidor no devolvió datos de sesión');
    }

    final session = AuthSession.fromLogin(data);
    if (session.accessToken.isEmpty || session.tenant.code.isEmpty) {
      throw ApiException.network('La respuesta de login está incompleta');
    }

    await _store.saveSession(session);
    await _store.setActiveTenant(session.tenant.code);
    return session;
  }

  /// Valida el token activo contra el backend y devuelve la identidad real.
  Future<CurrentIdentity> me() async {
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.authMe,
      parse: (raw) => (raw as Map).cast<String, dynamic>(),
    );

    final data = envelope.data;
    if (data == null) {
      throw ApiException.network('El servidor no devolvió la identidad');
    }

    final userJson =
        (data['user'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final tenantJson =
        (data['tenant'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    return CurrentIdentity(
      user: UserSummary.fromJson(userJson),
      tenant: TenantSummary.fromJson(tenantJson),
    );
  }

  Future<AuthSession?> restoreSession() => _store.readActiveSession();

  Future<bool> hasSession(String tenantCode) async {
    return await _store.readSession(tenantCode) != null;
  }

  /// Cambia el banco activo sin pedir contraseña si ya hay sesión guardada.
  Future<AuthSession> switchTenant(String tenantCode) async {
    final code = tenantCode.trim().toUpperCase();
    final session = await _store.readSession(code);
    if (session == null) {
      throw ApiException(
        code: 'SESSION_NOT_FOUND',
        message: 'No hay sesión guardada para $code',
        fieldErrors: <String, String>{'tenant_code': 'Inicia sesión en $code'},
      );
    }
    await _store.setActiveTenant(code);
    return session;
  }

  Future<List<AuthSession>> getSessions() async {
    final sessions = <AuthSession>[];
    for (final code in await _store.tenantCodes()) {
      final session = await _store.readSession(code);
      if (session != null) sessions.add(session);
    }
    return sessions;
  }

  Future<String?> activeTenantCode() => _store.getActiveTenant();

  /// Logout local: no existe logout en el backend.
  Future<void> logoutActive() => _store.clearActiveTenant();

  Future<void> logoutTenant(String tenantCode) =>
      _store.removeSession(tenantCode);

  Future<void> logoutAll() => _store.clearAll();

  Future<bool> isBiometricEnabled(String tenantCode) =>
      _store.isBiometricEnabled(tenantCode);

  Future<void> setBiometricEnabled(String tenantCode, bool enabled) =>
      _store.setBiometricEnabled(tenantCode, enabled);
}
