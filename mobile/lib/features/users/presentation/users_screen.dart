import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/users/data/users_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _email = TextEditingController();
  final _fullName = TextEditingController();
  final _password = TextEditingController();
  String _role = 'OPERATOR';

  bool _showForm = false;
  bool _saving = false;

  static const _roles = <String>['OPERATOR', 'TENANT_ADMIN', 'AUDITOR'];

  @override
  void dispose() {
    _email.dispose();
    _fullName.dispose();
    _password.dispose();
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
      await ref.read(usersRepositoryProvider).create(
            email: _email.text,
            fullName: _fullName.text,
            password: _password.text,
            role: _role,
          );
      ref.invalidate(usersProvider);
      ref.read(dataVersionProvider.notifier).state++;
      _email.clear();
      _fullName.clear();
      _password.clear();
      setState(() => _showForm = false);
      _message('Usuario creado correctamente');
    } on ApiException catch (error) {
      _message(error.displayMessage);
    } catch (_) {
      _message('No se pudo crear el usuario');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate =
        ref.watch(sessionControllerProvider).value?.user.canAdministrate ?? false;
    final async = ref.watch(usersProvider);
    final users = async.value?.items ?? const [];

    return AppScaffold(
      title: 'Usuarios',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Usuarios del banco',
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
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fullName,
                      decoration: const InputDecoration(labelText: 'Nombre completo'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña (mínimo 8 caracteres)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: _roles
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _role = value ?? 'OPERATOR'),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Crear usuario',
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
              'No se pudieron cargar los usuarios: ${async.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else if (users.isEmpty)
            const Text(
              'Todavía no hay usuarios en este banco',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...users.map(
              (user) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Icon(Icons.person_outline, color: AppColors.primary),
                  ),
                  title: Text(
                    user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(user.email),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        user.role,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        user.isActive ? 'Activo' : user.status,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
