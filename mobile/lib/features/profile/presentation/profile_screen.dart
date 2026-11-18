import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricEnabled = false;
  bool _checkingBiometrics = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    final session = ref.read(sessionControllerProvider).value;
    if (session == null) {
      if (mounted) setState(() => _checkingBiometrics = false);
      return;
    }
    final enabled = await ref
        .read(authRepositoryProvider)
        .isBiometricEnabled(session.tenant.code);
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _checkingBiometrics = false;
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    final session = ref.read(sessionControllerProvider).value;
    if (session == null) return;
    if (value && !await ref.read(biometricServiceProvider).isAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este dispositivo no tiene biometría disponible'),
        ),
      );
      return;
    }
    await ref
        .read(authRepositoryProvider)
        .setBiometricEnabled(session.tenant.code, value);
    setState(() => _biometricEnabled = value);
  }

  Future<void> _logout() async {
    await ref.read(sessionControllerProvider.notifier).logoutActive();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider).value;

    return AppScaffold(
      title: 'Perfil',
      showBottomNav: true,
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.surfaceMuted,
                    child: Icon(Icons.person, size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session?.user.fullName ?? 'Sin sesión',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session?.user.email ?? '',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Sesión activa',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _ProfileTile(
            icon: Icons.business,
            title: 'Institución',
            value: session?.tenant.name ?? '—',
          ),
          _ProfileTile(
            icon: Icons.badge_outlined,
            title: 'Rol',
            value: session?.user.role ?? '—',
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.account_balance, color: AppColors.primary),
              title: const Text(
                'Bancos y sesiones',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Cambia de institución sin volver a iniciar sesión',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => context.go('/banks'),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
              title: const Text(
                'Administración',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Módulos según tu rol: usuarios, clientes, tasas, auditoría...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => context.go('/admin'),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.fingerprint, color: AppColors.primary),
              title: const Text(
                'Desbloqueo con biometría',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Abre el token guardado tras iniciar sesión con contraseña',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: _checkingBiometrics
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Switch(
                      value: _biometricEnabled,
                      onChanged: _toggleBiometrics,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Cerrar sesión',
            icon: Icons.logout,
            outlined: true,
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(value, style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
