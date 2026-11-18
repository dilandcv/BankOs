import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/theme/tenant_theme.dart';
import 'package:mobile/features/tenants/data/tenants_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

/// Alta de instituciones: restringido a `PLATFORM_ADMIN` también en el backend.
class TenantsAdminScreen extends ConsumerStatefulWidget {
  const TenantsAdminScreen({super.key});

  @override
  ConsumerState<TenantsAdminScreen> createState() => _TenantsAdminScreenState();
}

class _TenantsAdminScreenState extends ConsumerState<TenantsAdminScreen> {
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _primary = TextEditingController(text: '#0070BA');
  final _secondary = TextEditingController(text: '#003087');
  final _logo = TextEditingController();

  bool _showForm = true;
  bool _saving = false;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _primary.dispose();
    _secondary.dispose();
    _logo.dispose();
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
      await ref.read(tenantsRepositoryProvider).create(
            code: _code.text,
            name: _name.text,
            primaryColor: _primary.text,
            secondaryColor: _secondary.text,
            logoUrl: _logo.text,
          );
      ref.invalidate(tenantsProvider);
      ref.read(dataVersionProvider.notifier).state++;
      _code.clear();
      _name.clear();
      _logo.clear();
      _message('Institución creada correctamente');
    } on ApiException catch (error) {
      _message(error.displayMessage);
    } catch (_) {
      _message('No se pudo crear la institución');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate =
        ref.watch(sessionControllerProvider).value?.user.canCreateTenant ?? false;
    final async = ref.watch(tenantsProvider);
    final tenants = async.value ?? const [];

    return AppScaffold(
      title: 'Instituciones',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!canCreate)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Solo PLATFORM_ADMIN puede crear instituciones. '
                'Estás viendo el catálogo disponible.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          if (canCreate) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nueva institución',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _showForm = !_showForm),
                  icon: const Icon(Icons.add),
                  label: Text(_showForm ? 'Ocultar' : 'Mostrar'),
                ),
              ],
            ),
            if (_showForm) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _code,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Código (BANCO_NUEVO)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _primary,
                              decoration: const InputDecoration(
                                labelText: 'Color primario',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _secondary,
                              decoration: const InputDecoration(
                                labelText: 'Color secundario',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _logo,
                        decoration: const InputDecoration(
                          labelText: 'URL del logo (opcional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Crear institución',
                        icon: Icons.save_outlined,
                        loading: _saving,
                        onPressed: _create,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),
          const Text(
            'Instituciones registradas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (async.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (async.hasError)
            Text(
              'No se pudieron cargar las instituciones: ${async.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else if (tenants.isEmpty)
            const Text(
              'No hay instituciones disponibles',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...tenants.map(
              (tenant) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (TenantTheme.parseHex(tenant.primaryColor) ??
                            AppColors.primary)
                        .withValues(alpha: 0.15),
                    child: Icon(
                      Icons.account_balance,
                      color: TenantTheme.parseHex(tenant.primaryColor) ??
                          AppColors.primary,
                    ),
                  ),
                  title: Text(
                    tenant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text('${tenant.code} · ${tenant.status}'),
                  trailing: Text(
                    tenant.primaryColor,
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
