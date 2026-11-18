import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';

class AdminHubScreen extends ConsumerWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).value?.user;
    if (user == null) return const SizedBox.shrink();

    final items = <_AdminItem>[
      if (user.canViewUsers)
        const _AdminItem(
          icon: Icons.manage_accounts,
          title: 'Usuarios',
          subtitle: 'Altas y consulta de usuarios del banco',
          route: '/admin/users',
        ),
      if (user.canViewCustomers)
        const _AdminItem(
          icon: Icons.people_alt_outlined,
          title: 'Clientes',
          subtitle: 'Documentos y datos de clientes',
          route: '/admin/customers',
        ),
      if (user.canViewSettings)
        const _AdminItem(
          icon: Icons.tune,
          title: 'Configuración y tasas',
          subtitle: 'Comisiones y tasas de cambio por institución',
          route: '/admin/settings',
        ),
      if (user.canViewAudit)
        const _AdminItem(
          icon: Icons.history_toggle_off,
          title: 'Auditoría',
          subtitle: 'Trazabilidad de acciones sensibles',
          route: '/admin/audit',
        ),
      if (user.canViewWebhooks)
        const _AdminItem(
          icon: Icons.webhook,
          title: 'Webhooks y outbox',
          subtitle: 'Suscripciones y eventos pendientes',
          route: '/admin/webhooks',
        ),
      if (user.canCreateTenant)
        const _AdminItem(
          icon: Icons.account_balance,
          title: 'Instituciones',
          subtitle: 'Alta de nuevos bancos en la plataforma',
          route: '/admin/tenants',
        ),
    ];

    return AppScaffold(
      title: 'Administración',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hola, ${user.fullName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rol: ${user.role} · Módulos autorizados para tu perfil',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            const Text(
              'Tu rol no tiene módulos de administración disponibles',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...items.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Icon(
                      item.icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => context.go(item.route),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminItem {
  const _AdminItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}
