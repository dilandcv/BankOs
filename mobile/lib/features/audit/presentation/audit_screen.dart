import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/features/audit/data/audit_log.dart';
import 'package:mobile/features/audit/data/audit_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';

class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(auditLogsProvider);
    final logs = async.value?.items ?? const [];

    Future<void> showDetail(AuditLogModel log) async {
      try {
        final detail = await ref.read(auditRepositoryProvider).byId(log.id);
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(detail.action),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _line('ID', detail.id),
                  _line('Recurso', '${detail.resourceType} · ${detail.resourceId}'),
                  _line('Actor', detail.actorUserId),
                  _line('Correlación', detail.correlationId),
                  _line('Fecha', detail.createdAt),
                  const SizedBox(height: 8),
                  const Text(
                    'Metadata',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail.metadata.isEmpty ? '—' : detail.metadata,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      } on ApiException catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.displayMessage)),
        );
      }
    }

    return AppScaffold(
      title: 'Auditoría',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Registros de auditoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Acciones sensibles del banco activo (Admin/Auditor)',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (async.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (async.hasError)
            Text(
              'No se pudo cargar la auditoría: ${async.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else if (logs.isEmpty)
            const Text(
              'Todavía no hay registros de auditoría',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...logs.map(
              (log) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Icon(
                      Icons.fact_check_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    log.action,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text('${log.resourceType} · ${log.shortDate}'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => showDetail(log),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
