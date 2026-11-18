import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/core/theme/tenant_theme.dart';
import 'package:mobile/features/tenants/presentation/add_bank_sheet.dart';
import 'package:mobile/shared/constants/app_colors.dart';

class BankSwitcherBottomSheet extends ConsumerStatefulWidget {
  const BankSwitcherBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BankSwitcherBottomSheet(),
    );
  }

  @override
  ConsumerState<BankSwitcherBottomSheet> createState() =>
      _BankSwitcherBottomSheetState();
}

class _BankSwitcherBottomSheetState
    extends ConsumerState<BankSwitcherBottomSheet> {
  String? _switchingCode;

  Future<void> _selectBank(LinkedBankModel bank) async {
    final activeCode =
        ref.read(sessionControllerProvider).value?.tenant.code;

    // Si ya está en este banco, solo cierra
    if (activeCode == bank.tenantCode) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _switchingCode = bank.tenantCode);

    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .switchBank(bank.tenantCode);

      if (!mounted) return;
      Navigator.of(context).pop();
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cambiar a ${bank.tenantName}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _switchingCode = null);
    }
  }

  void _openAddBank() {
    Navigator.of(context).pop();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBankAccountSheet(),
    );
  }

  void _goToHub() {
    ref.read(sessionControllerProvider.notifier).clearActiveBank();
    Navigator.of(context).pop();
    context.go('/hub');
  }

  @override
  Widget build(BuildContext context) {
    final linkedBanks = ref.watch(linkedBanksProvider);
    final activeSession = ref.watch(sessionControllerProvider).value;
    final activeTenantCode = activeSession?.tenant.code;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle de arrastre superior
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Encabezado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tus Cuentas Bancarias',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Cambia al instante con un solo toque',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _goToHub,
                    icon: const Icon(Icons.home_outlined, size: 16),
                    label: const Text('Inicio Central'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0070BA),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Lista de bancos estilo Instagram
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: linkedBanks.length,
                itemBuilder: (context, index) {
                  final bank = linkedBanks[index];
                  final isActive = bank.tenantCode == activeTenantCode;
                  final isSwitching = _switchingCode == bank.tenantCode;
                  final brandColor =
                      TenantTheme.parseHex(bank.primaryColor) ??
                          AppColors.primary;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? brandColor.withOpacity(0.06)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? brandColor
                            : AppColors.border.withOpacity(0.5),
                        width: isActive ? 1.8 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      onTap: isSwitching ? null : () => _selectBank(bank),
                      leading: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Anillo activo estilo Instagram Story
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isActive
                                  ? LinearGradient(
                                      colors: [
                                        brandColor,
                                        TenantTheme.parseHex(
                                                bank.secondaryColor) ??
                                            brandColor,
                                      ],
                                    )
                                  : null,
                              color: isActive ? null : AppColors.surfaceMuted,
                            ),
                            padding: const EdgeInsets.all(2.5),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: brandColor,
                                size: 22,
                              ),
                            ),
                          ),
                          if (isActive)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: brandColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Text(
                            bank.tenantName,
                            style: TextStyle(
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: brandColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Activa',
                                style: TextStyle(
                                  color: brandColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        bank.accountNickname.isNotEmpty
                            ? bank.accountNickname
                            : bank.accountNumberMask,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: isSwitching
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: brandColor,
                              ),
                            )
                          : isActive
                              ? Icon(Icons.check_circle,
                                  color: brandColor, size: 22)
                              : const Icon(Icons.swap_horiz,
                                  color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            // Opción de agregar nueva cuenta bancaria
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                onTap: _openAddBank,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: const Color(0xFF0070BA).withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0070BA).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF0070BA),
                    size: 22,
                  ),
                ),
                title: const Text(
                  '+ Agregar cuenta bancaria',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0070BA),
                  ),
                ),
                subtitle: const Text(
                  'Vincula una nueva entidad financiera',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF0070BA),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
