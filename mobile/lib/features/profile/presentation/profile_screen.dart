import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/core/theme/tenant_theme.dart';
import 'package:mobile/features/tenants/presentation/add_bank_sheet.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/bank_switcher_bottom_sheet.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricEnabled = false;
  bool _checkingBiometrics = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    final enabled =
        await ref.read(authRepositoryProvider).isMasterBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _checkingBiometrics = false;
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value && !await ref.read(biometricServiceProvider).isAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este dispositivo no tiene biometría disponible'),
        ),
      );
      return;
    }
    await ref.read(authRepositoryProvider).setMasterBiometricEnabled(value);
    setState(() => _biometricEnabled = value);
  }

  Future<void> _setDefaultBank(LinkedBankModel bank) async {
    setState(() => _actionLoading = true);
    try {
      await ref.read(authRepositoryProvider).setDefaultBank(bank.linkId);
      await ref
          .read(masterSessionControllerProvider.notifier)
          .reloadLinkedBanks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${bank.tenantName} marcada como cuenta predeterminada'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _confirmUnlink(LinkedBankModel bank) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Desvincular ${bank.tenantName}?'),
        content: Text(
          'Esta acción eliminará el vínculo de ${bank.tenantName} de tu cuenta BankOS. '
          'Tu cuenta principal y tus otras entidades bancarias no se verán afectadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Desvincular'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _actionLoading = true);
    try {
      await ref.read(authRepositoryProvider).unlinkBank(bank.linkId);
      await ref
          .read(masterSessionControllerProvider.notifier)
          .reloadLinkedBanks();

      // Si el banco desvinculado era el activo, limpia la sesión activa de banco
      final activeCode =
          ref.read(sessionControllerProvider).value?.tenant.code;
      if (activeCode == bank.tenantCode) {
        await ref.read(sessionControllerProvider.notifier).clearActiveBank();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${bank.tenantName} desvinculada correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _reauthorizeBank(LinkedBankModel bank) async {
    setState(() => _actionLoading = true);
    try {
      await ref.read(authRepositoryProvider).reauthorizeBank(bank.linkId);
      await ref
          .read(masterSessionControllerProvider.notifier)
          .reloadLinkedBanks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${bank.tenantName} reautorizada con éxito'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(masterSessionControllerProvider.notifier).logout();
    if (!mounted) return;
    context.go('/login');
  }

  void _showAddBankSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBankAccountSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterSession = ref.watch(masterSessionControllerProvider).value;
    final activeBankSession = ref.watch(sessionControllerProvider).value;
    final linkedBanks = ref.watch(linkedBanksProvider);

    final userName = masterSession?.user.fullName ??
        activeBankSession?.user.fullName ??
        'Usuario';
    final userEmail = masterSession?.user.email ??
        activeBankSession?.user.email ??
        '';

    return AppScaffold(
      title: 'Perfil',
      showBottomNav: true,
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta de identidad maestra
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF0070BA).withOpacity(0.12),
                    child: const Icon(
                      Icons.person,
                      size: 38,
                      color: Color(0xFF0070BA),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0070BA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      activeBankSession != null
                          ? 'Operando en: ${activeBankSession.tenant.name}'
                          : 'Sesión Central BankOS',
                      style: const TextStyle(
                        color: Color(0xFF0070BA),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Selector rápido estilo Instagram
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(
                Icons.swap_horiz,
                color: Color(0xFF0070BA),
              ),
              title: const Text(
                'Cambiar de cuenta bancaria',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Cambio rápido en 1 toque (Estilo Instagram)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onTap: () => BankSwitcherBottomSheet.show(context),
            ),
          ),

          // SECCIÓN REQUERIDA: "Mis cuentas bancarias"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis cuentas bancarias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddBankSheet,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0070BA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (linkedBanks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No tienes entidades vinculadas.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            ...linkedBanks.map((bank) {
              final color = TenantTheme.parseHex(bank.primaryColor) ??
                  AppColors.primary;
              final isCurrent =
                  bank.tenantCode == activeBankSession?.tenant.code;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isCurrent ? color : AppColors.border,
                    width: isCurrent ? 1.5 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(Icons.account_balance,
                                color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      bank.tenantName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (bank.isDefault) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Predeterminada',
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${bank.accountNickname} • ${bank.accountNumberMask}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Estado de conexión
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: bank.isConnected
                                  ? AppColors.success.withOpacity(0.12)
                                  : AppColors.warning.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: bank.isConnected
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  bank.isConnected
                                      ? 'Conectada'
                                      : 'Reautorizar',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: bank.isConnected
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      // Acciones de gestión requeridas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!bank.isDefault)
                            TextButton(
                              onPressed: _actionLoading
                                  ? null
                                  : () => _setDefaultBank(bank),
                              child: const Text('Hacer predeterminada',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          if (!bank.isConnected)
                            TextButton(
                              onPressed: _actionLoading
                                  ? null
                                  : () => _reauthorizeBank(bank),
                              child: const Text('Reautorizar',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.warning)),
                            ),
                          TextButton(
                            onPressed: _actionLoading
                                ? null
                                : () => _confirmUnlink(bank),
                            child: const Text(
                              'Desvincular',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 16),
          const Text(
            'Seguridad y Configuración',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(
                Icons.fingerprint,
                color: Color(0xFF0070BA),
              ),
              title: const Text(
                'Desbloqueo biométrico',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Ingresa con huella o Face ID a tu cuenta BankOS',
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

          if (activeBankSession?.user.canAdministrate == true)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings,
                  color: Color(0xFF0070BA),
                ),
                title: const Text(
                  'Administración bancaria',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Panel administrativo de ${activeBankSession!.tenant.name}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
                onTap: () => context.go('/admin'),
              ),
            ),

          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Cerrar sesión en BankOS',
            icon: Icons.logout,
            outlined: true,
            onPressed: _logout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
