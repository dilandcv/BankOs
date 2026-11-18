import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/core/theme/tenant_theme.dart';
import 'package:mobile/features/auth/data/auth_providers.dart';
import 'package:mobile/features/tenants/data/tenant.dart';
import 'package:mobile/features/tenants/data/tenants_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';

class BanksScreen extends ConsumerWidget {
  const BanksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantsProvider);
    final sessionsAsync = ref.watch(savedSessionsProvider);
    final activeCode = ref.watch(sessionControllerProvider).value?.tenant.code;
    final tenants = tenantsAsync.value ?? const <TenantModel>[];
    final sessions = sessionsAsync.value ?? const <AuthSession>[];

    final localCodes = sessions.map((session) => session.tenant.code).toSet();
    final allCodes = <String>{
      ...tenants.map((tenant) => tenant.code),
      ...localCodes,
    }.toList()
      ..sort();

    String nameFor(String code) {
      for (final tenant in tenants) {
        if (tenant.code == code) return tenant.name;
      }
      for (final session in sessions) {
        if (session.tenant.code == code) return session.tenant.name;
      }
      return code;
    }

    String? logoFor(String code) {
      for (final tenant in tenants) {
        if (tenant.code == code) return tenant.logoUrl;
      }
      for (final session in sessions) {
        if (session.tenant.code == code) return session.tenant.logoUrl;
      }
      return null;
    }

    Color colorFor(String code) {
      for (final tenant in tenants) {
        if (tenant.code == code) {
          return TenantTheme.parseHex(tenant.primaryColor) ?? AppColors.primary;
        }
      }
      for (final session in sessions) {
        if (session.tenant.code == code) {
          return TenantTheme.parseHex(session.tenant.primaryColor) ??
              AppColors.primary;
        }
      }
      return AppColors.primary;
    }

    Future<void> select(String code) async {
      final session = sessions.where((s) => s.tenant.code == code).toList();
      if (session.isEmpty || session.first.isExpired()) {
        if (session.isNotEmpty) {
          await ref.read(authRepositoryProvider).logoutTenant(code);
        }
        if (context.mounted) context.go('/login', extra: code);
        return;
      }
      await ref.read(sessionControllerProvider.notifier).switchTenant(code);
      if (context.mounted) context.go('/dashboard');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bancos y sesiones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Instituciones disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cada banco conserva su propio token y tema',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (tenantsAsync.isLoading || sessionsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ...allCodes.map((code) {
              final session = sessions.where((s) => s.tenant.code == code).toList();
              final hasSession = session.isNotEmpty;
              final expired = hasSession && session.first.isExpired();
              final isActive = activeCode == code;
              final logo = logoFor(code);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorFor(code).withValues(alpha: 0.12),
                    child: logo != null && logo.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              logo,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.account_balance,
                                color: colorFor(code),
                              ),
                            ),
                          )
                        : Icon(Icons.account_balance, color: colorFor(code)),
                  ),
                  title: Text(
                    nameFor(code),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    isActive
                        ? 'Banco activo · sesión vigente'
                        : (expired
                            ? 'Token vencido · requiere contraseña'
                            : (hasSession
                                ? 'Sesión guardada · cambio sin login'
                                : 'Sin sesión guardada')),
                    style: TextStyle(
                      color: expired ? AppColors.warning : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () => select(code),
                    child: Text(
                      isActive
                          ? 'Activo'
                          : (hasSession && !expired ? 'Cambiar' : 'Ingresar'),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
