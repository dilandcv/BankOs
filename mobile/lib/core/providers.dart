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

/// Controlador de la sesión maestra de BankOS.
final masterSessionControllerProvider =
    AsyncNotifierProvider<MasterSessionController, MasterSession?>(
        MasterSessionController.new);

class MasterSessionController extends AsyncNotifier<MasterSession?> {
  @override
  Future<MasterSession?> build() async {
    final store = ref.watch(secureSessionStoreProvider);
    final session = await store.readMasterSession();
    if (session == null) return null;
    if (session.isExpired()) {
      await store.clearMasterSession();
      return null;
    }
    return session;
  }

  Future<void> setSession(MasterSession session) async {
    final store = ref.read(secureSessionStoreProvider);
    await store.saveMasterSession(session);
    state = AsyncData(session);
  }

  Future<void> reloadLinkedBanks() async {
    final current = state.value;
    if (current == null) return;
    try {
      final banks = await ref.read(authRepositoryProvider).getLinkedBanks();
      final updated = current.copyWith(linkedBanks: banks);
      await ref.read(secureSessionStoreProvider).saveMasterSession(updated);
      state = AsyncData(updated);
    } catch (_) {
      // Ignora error si falla red para no desloguear
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logoutAll();
    ref.read(sessionControllerProvider.notifier).clearActiveBank();
    state = const AsyncData(null);
  }
}

/// Sesión del banco activo. `null` significa que el usuario está en el Hub de BankOS.
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

  /// Cambia al banco especificado canjeando el token si es necesario.
  Future<AuthSession> switchBank(String tenantCode) async {
    final repo = ref.read(authRepositoryProvider);
    final session = await repo.switchTenant(tenantCode);
    state = AsyncData(session);
    return session;
  }

  Future<void> switchTenant(String tenantCode) => switchBank(tenantCode);

  Future<void> clearActiveBank() async {
    await ref.read(secureSessionStoreProvider).clearActiveTenant();
    state = const AsyncData(null);
  }

  Future<void> logoutActive() async {
    await clearActiveBank();
  }

  Future<void> logoutTenant(String tenantCode) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logoutTenant(tenantCode);
    final active = await repo.activeTenantCode();
    if (active == null) state = const AsyncData(null);
  }

  Future<void> handleUnauthorized() => refresh();
}

final isMasterAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(masterSessionControllerProvider).value != null;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(isMasterAuthenticatedProvider);
});

final linkedBanksProvider = Provider<List<LinkedBankModel>>((ref) {
  return ref.watch(masterSessionControllerProvider).value?.linkedBanks ?? const [];
});

/// Tema dinámico: Si hay banco activo, usa los colores del banco; si no, usa BankOS Platform.
final tenantThemeProvider = Provider<TenantTheme>((ref) {
  final bankSession = ref.watch(sessionControllerProvider).value;
  if (bankSession != null) {
    return TenantTheme.fromSession(bankSession);
  }
  return TenantTheme.fallback();
});

/// Se incrementa tras una operación financiera para recargar saldos e historial.
final dataVersionProvider = StateProvider<int>((ref) => 0);

/// Mensaje de error global para mostrar en snackbars sin acoplar al widget.
final userMessageProvider = StateProvider<String?>((ref) => null);

void showApiError(WidgetRef ref, Object error) {
  ref.read(userMessageProvider.notifier).state =
      error is ApiException ? error.displayMessage : 'Error inesperado';
}
