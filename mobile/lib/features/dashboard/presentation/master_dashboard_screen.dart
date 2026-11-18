import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/core/theme/tenant_theme.dart';
import 'package:mobile/features/tenants/presentation/add_bank_sheet.dart';
import 'package:mobile/shared/constants/app_colors.dart';

class MasterDashboardScreen extends ConsumerStatefulWidget {
  const MasterDashboardScreen({super.key});

  @override
  ConsumerState<MasterDashboardScreen> createState() =>
      _MasterDashboardScreenState();
}

class _MasterDashboardScreenState extends ConsumerState<MasterDashboardScreen> {
  String? _switchingTenantCode;

  Future<void> _openBank(LinkedBankModel bank) async {
    setState(() => _switchingTenantCode = bank.tenantCode);

    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .switchBank(bank.tenantCode);

      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo ingresar a ${bank.tenantName}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _switchingTenantCode = null);
    }
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
    final linkedBanks = ref.watch(linkedBanksProvider);

    final fullName = masterSession?.user.fullName.isNotEmpty == true
        ? masterSession!.user.fullName
        : 'Usuario';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1F3A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0070BA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              'BankOS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mi perfil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            tooltip: 'Cerrar sesión global',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref
                  .read(masterSessionControllerProvider.notifier)
                  .logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(masterSessionControllerProvider.notifier)
              .reloadLinkedBanks(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // Saludo dinámico requerido
              Text(
                '¡Hola, $fullName!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '¿A dónde quieres ir hoy?',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Cabecera de entidades vinculadas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tus entidades bancarias (${linkedBanks.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddBankSheet,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Agregar banco'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0070BA),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista de bancos autorizados y vinculados
              if (linkedBanks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        'Aún no tienes bancos vinculados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Vincula tu primera cuenta bancaria para comenzar a gestionar tus finanzas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: _showAddBankSheet,
                        icon: const Icon(Icons.add),
                        label: const Text('Vincular cuenta bancaria'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0070BA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...linkedBanks.map((bank) {
                  final isSwitching = _switchingTenantCode == bank.tenantCode;
                  final primary =
                      TenantTheme.parseHex(bank.primaryColor) ?? AppColors.primary;
                  final secondary =
                      TenantTheme.parseHex(bank.secondaryColor) ??
                          AppColors.primaryDark;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _BankVisualCard(
                      bank: bank,
                      primaryColor: primary,
                      secondaryColor: secondary,
                      loading: isSwitching,
                      onTap: () => _openBank(bank),
                    ),
                  );
                }),

              // Botón destacado: + Agregar cuenta bancaria
              InkWell(
                onTap: _showAddBankSheet,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF0070BA).withOpacity(0.4),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0070BA).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFF0070BA),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '+ Agregar cuenta bancaria',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0070BA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              // Resumen de seguridad
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined,
                        size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tus credenciales bancarias están protegidas con cifrado y autorizaciones independientes.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankVisualCard extends StatelessWidget {
  const _BankVisualCard({
    required this.bank,
    required this.primaryColor,
    required this.secondaryColor,
    required this.loading,
    required this.onTap,
  });

  final LinkedBankModel bank;
  final Color primaryColor;
  final Color secondaryColor;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bank.tenantName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            bank.accountNickname.isNotEmpty
                                ? bank.accountNickname
                                : bank.accountType,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (bank.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Principal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Número de cuenta',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bank.accountNumberMask.isNotEmpty
                            ? bank.accountNumberMask
                            : '•••• ••••',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  // Botón de acción claro para ingresar
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ingresar',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: primaryColor,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
