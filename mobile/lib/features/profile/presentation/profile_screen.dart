import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/constants/mock_data.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  const Text(
                    MockData.userName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(MockData.tenantName, style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Sesión activa', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _ProfileTile(icon: Icons.business, title: 'Institución', value: MockData.tenantName),
          _ProfileTile(icon: Icons.badge_outlined, title: 'Rol', value: 'Usuario'),
          _ProfileTile(icon: Icons.shield_outlined, title: 'Seguridad', value: 'Biometría disponible'),
          _ProfileTile(icon: Icons.settings_outlined, title: 'Configuración', value: 'Preferencias de cuenta'),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Cerrar sesión',
            icon: Icons.logout,
            outlined: true,
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends ConsumerWidget {
  const _ProfileTile({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(value, style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}
