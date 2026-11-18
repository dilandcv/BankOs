import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/webhooks/data/webhooks_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class WebhooksScreen extends ConsumerStatefulWidget {
  const WebhooksScreen({super.key});

  @override
  ConsumerState<WebhooksScreen> createState() => _WebhooksScreenState();
}

class _WebhooksScreenState extends ConsumerState<WebhooksScreen> {
  final _url = TextEditingController();
  final _events = TextEditingController(text: 'transaction.completed');
  final _secret = TextEditingController();

  bool _showForm = false;
  bool _saving = false;

  @override
  void dispose() {
    _url.dispose();
    _events.dispose();
    _secret.dispose();
    super.dispose();
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _create() async {
    setState(() => _saving = true);
    try {
      await ref.read(webhooksRepositoryProvider).create(
            url: _url.text,
            events: _events.text,
            secret: _secret.text,
          );
      ref.invalidate(webhooksProvider);
      ref.read(dataVersionProvider.notifier).state++;
      _url.clear();
      _secret.clear();
      setState(() => _showForm = false);
      _message('Webhook creado correctamente');
    } on ApiException catch (error) {
      _message(error.displayMessage);
    } catch (_) {
      _message('No se pudo crear el webhook');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManage =
        ref.watch(sessionControllerProvider).value?.user.canManageWebhooks ?? false;
    final hooksAsync = ref.watch(webhooksProvider);
    final eventsAsync = ref.watch(outboxEventsProvider);
    final hooks = hooksAsync.value ?? const [];
    final events = eventsAsync.value?.items ?? const [];

    return AppScaffold(
      title: 'Webhooks y outbox',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Configuraciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (canManage)
                TextButton.icon(
                  onPressed: () => setState(() => _showForm = !_showForm),
                  icon: const Icon(Icons.add),
                  label: Text(_showForm ? 'Ocultar' : 'Nuevo'),
                ),
            ],
          ),
          if (_showForm && canManage) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _url,
                      decoration: const InputDecoration(labelText: 'URL del endpoint'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _events,
                      decoration: const InputDecoration(labelText: 'Eventos'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _secret,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Secreto (mínimo 16 caracteres)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Crear webhook',
                      icon: Icons.save_outlined,
                      loading: _saving,
                      onPressed: _create,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (hooksAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (hooksAsync.hasError)
            Text(
              'No se pudieron cargar los webhooks: ${hooksAsync.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else if (hooks.isEmpty)
            const Text(
              'No hay webhooks configurados',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...hooks.map(
              (hook) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Icon(
                      Icons.webhook,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    hook.url,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text('Eventos: ${hook.events}'),
                  trailing: Text(
                    hook.status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Outbox de eventos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'El secreto nunca se devuelve en las respuestas',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          if (eventsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (eventsAsync.hasError)
            Text(
              'No se pudo cargar el outbox: ${eventsAsync.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else if (events.isEmpty)
            const Text(
              'No hay eventos pendientes',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...events.map(
              (event) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Icon(
                      event.status.toUpperCase() == 'DEAD'
                          ? Icons.error_outline
                          : Icons.send_outlined,
                      color: event.status.toUpperCase() == 'DEAD'
                          ? AppColors.danger
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    event.eventType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text('Intentos: ${event.attempts} · ${event.status}'),
                  trailing: Text(
                    event.id.substring(0, event.id.length.clamp(0, 8)),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
