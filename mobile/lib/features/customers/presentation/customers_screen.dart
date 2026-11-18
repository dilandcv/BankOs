import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/customers/data/customers_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _documentType = TextEditingController(text: 'CC');
  final _documentNumber = TextEditingController();
  final _fullName = TextEditingController();

  bool _showForm = false;
  bool _saving = false;

  static const _documentTypes = <String>['CC', 'TI', 'NIT', 'PA', 'CE'];

  @override
  void dispose() {
    _documentType.dispose();
    _documentNumber.dispose();
    _fullName.dispose();
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
      await ref.read(customersRepositoryProvider).create(
            documentType: _documentType.text,
            documentNumber: _documentNumber.text,
            fullName: _fullName.text,
          );
      ref.invalidate(customersProvider);
      ref.read(dataVersionProvider.notifier).state++;
      _documentNumber.clear();
      _fullName.clear();
      setState(() => _showForm = false);
      _message('Cliente creado correctamente');
    } on ApiException catch (error) {
      _message(error.displayMessage);
    } catch (_) {
      _message('No se pudo crear el cliente');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate =
        ref.watch(sessionControllerProvider).value?.user.canManageCustomers ?? false;
    final async = ref.watch(customersProvider);
    final customers = async.value?.items ?? const [];

    return AppScaffold(
      title: 'Clientes',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Clientes del banco',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (canCreate)
                TextButton.icon(
                  onPressed: () => setState(() => _showForm = !_showForm),
                  icon: const Icon(Icons.person_add_outlined),
                  label: Text(_showForm ? 'Ocultar' : 'Nuevo'),
                ),
            ],
          ),
          if (_showForm && canCreate) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _documentType.text,
                      decoration: const InputDecoration(labelText: 'Tipo de documento'),
                      items: _documentTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _documentType.text = value ?? 'CC'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _documentNumber,
                      decoration: const InputDecoration(labelText: 'Número de documento'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fullName,
                      decoration: const InputDecoration(labelText: 'Nombre completo'),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Crear cliente',
                      icon: Icons.save_outlined,
                      loading: _saving,
                      onPressed: _create,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (async.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (async.hasError)
            Text(
              'No se pudieron cargar los clientes: ${async.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else if (customers.isEmpty)
            const Text(
              'Todavía no hay clientes en este banco',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...customers.map(
              (customer) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Icon(
                      Icons.person_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    customer.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text('${customer.documentType} · ${customer.documentNumber}'),
                  trailing: Text(
                    customer.isActive ? 'Activo' : customer.status,
                    style: const TextStyle(
                      fontSize: 12,
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
