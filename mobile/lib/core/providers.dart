import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/api_config.dart';
import 'network/api_client.dart';
import 'network/api_exception.dart';
import 'security/biometric_service.dart';
import 'session/auth_session.dart';
import 'storage/secure_session_store.dart';
import 'theme/tenant_theme.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';

final secureSessionStoreProvider = Provider<SecureSessionStore>((ref) {
  return SecureSessionStore();
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: ApiConfig.baseUrl,
    sessionStore: ref.watch(secureSessionStoreProvider),
    dio: ref.watch(dioProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureSessionStoreProvider),
  );
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Sesión del banco activo. `null` significa que hay que hacer login.
final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, AuthSession?>(SessionController.new);

class SessionController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final store = ref.watch(secureSessionStoreProvider);
    final code = await store.getActiveTenant();
    if (code == null) return null;

    final session = await store.readSession(code);
    if (session == null) return null;
    if (session.isExpired()) {
      await store.clearActiveTenant();
      return null;
    }
    return session;
  }

  Future<void> setSession(AuthSession session) async {
    final store = ref.read(secureSessionStoreProvider);
    await store.saveSession(session);
    await store.setActiveTenant(session.tenant.code);
    state = AsyncData(session);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final store = ref.read(secureSessionStoreProvider);
      final code = await store.getActiveTenant();
      if (code == null) return null;
      final session = await store.readSession(code);
      if (session == null || session.isExpired()) return null;
      return session;
    });
  }

  Future<void> switchTenant(String tenantCode) async {
    final session = await ref
        .read(authRepositoryProvider)
        .switchTenant(tenantCode);
    state = AsyncData(session);
  }

  Future<void> logoutActive() async {
    await ref.read(authRepositoryProvider).logoutActive();
    state = const AsyncData(null);
  }

  Future<void> logoutTenant(String tenantCode) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logoutTenant(tenantCode);
    final active = await repo.activeTenantCode();
    if (active == null) state = const AsyncData(null);
  }

  /// El interceptor ya limpió el tenant activo ante un 401; reflejamos el cambio.
  Future<void> handleUnauthorized() => refresh();
}

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(sessionControllerProvider).value != null;
});

/// Tema del banco activo (se aplicará en F3).
final tenantThemeProvider = Provider<TenantTheme>((ref) {
  final session = ref.watch(sessionControllerProvider).value;
  return TenantTheme.fromSession(session);
});

/// Se incrementa tras una operación financiera para recargar saldos e historial.
final dataVersionProvider = StateProvider<int>((ref) => 0);

/// Mensaje de error global para mostrar en sn bars sin acoplar al widget.
final userMessageProvider = StateProvider<String?>((ref) => null);

void showApiError(WidgetRef ref, Object error) {
  ref.read(userMessageProvider.notifier).state =
      error is ApiException ? error.displayMessage : 'Error inesperado';
}
