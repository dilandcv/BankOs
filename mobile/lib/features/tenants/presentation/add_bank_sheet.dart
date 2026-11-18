import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/core/theme/tenant_theme.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class AddBankAccountSheet extends ConsumerStatefulWidget {
  const AddBankAccountSheet({super.key});

  @override
  ConsumerState<AddBankAccountSheet> createState() =>
      _AddBankAccountSheetState();
}

class _AddBankAccountSheetState extends ConsumerState<AddBankAccountSheet> {
  int _step = 0; // 0 = Seleccionar banco, 1 = Configurar y Autorizar, 2 = Éxito
  LinkedBankModel? _selectedBank;
  String _accountType = 'SAVINGS';
  final _nicknameController = TextEditingController();

  List<LinkedBankModel> _availableBanks = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAvailableBanks();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableBanks() async {
    try {
      final banks = await ref.read(authRepositoryProvider).getAvailableBanks();
      final linkedCodes = ref
          .read(linkedBanksProvider)
          .map((b) => b.tenantCode)
          .toSet();

      // Filtra las que aún no están vinculadas
      final unlinked =
          banks.where((b) => !linkedCodes.contains(b.tenantCode)).toList();

      if (mounted) {
        setState(() {
          _availableBanks = unlinked;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar las entidades disponibles: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _submitLink() async {
    if (_selectedBank == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).linkBank(
            tenantCode: _selectedBank!.tenantCode,
            accountNickname: _nicknameController.text.trim().isNotEmpty
                ? _nicknameController.text.trim()
                : '${_selectedBank!.tenantName} Principal',
            accountType: _accountType,
            consentToken: 'oauth2_consent_valid_token',
          );

      // Recarga la lista en el controlador maestro para refrescar el Dashboard
      await ref
          .read(masterSessionControllerProvider.notifier)
          .reloadLinkedBanks();

      if (mounted) {
        setState(() {
          _step = 2; // Pantalla de éxito
          _submitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al vincular: $e';
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildSelectBankStep();
      case 1:
        return _buildAuthorizeStep();
      case 2:
        return _buildSuccessStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSelectBankStep() {
    return Column(
      key: const ValueKey('step_select'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Vincular nueva cuenta bancaria',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Selecciona la entidad financiera que deseas integrar a BankOS:',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        if (_loading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_error!, style: const TextStyle(color: AppColors.error)),
          )
        else if (_availableBanks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 40, color: Color(0xFF0070BA)),
                SizedBox(height: 8),
                Text(
                  '¡Todas las entidades ya están vinculadas!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Actualmente tienes acceso a todos los bancos disponibles.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _availableBanks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final bank = _availableBanks[index];
                final color = TenantTheme.parseHex(bank.primaryColor) ??
                    AppColors.primary;

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  tileColor: Colors.white,
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.12),
                    child: Icon(Icons.account_balance, color: color, size: 20),
                  ),
                  title: Text(
                    bank.tenantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: const Text(
                    'Integración segura Open Banking (OAuth 2.0)',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                  onTap: () {
                    setState(() {
                      _selectedBank = bank;
                      _nicknameController.text = '${bank.tenantName} Personal';
                      _step = 1;
                    });
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAuthorizeStep() {
    final bank = _selectedBank!;
    final color =
        TenantTheme.parseHex(bank.primaryColor) ?? const Color(0xFF0070BA);

    return Column(
      key: const ValueKey('step_auth'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _step = 0),
            ),
            Expanded(
              child: Text(
                'Autorizar ${bank.tenantName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Aviso de seguridad y mecanismo oficial
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conexión segura y cifrada',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'BankOS no almacena contraseñas bancarias en texto plano. La vinculación utiliza consentimientos y tokens autorizados.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Nombre / Alias
        TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(
            labelText: 'Alias para esta cuenta',
            hintText: 'Ej. Mi Nequi, Cuenta de ahorros...',
          ),
        ),
        const SizedBox(height: 14),

        // Tipo de cuenta
        DropdownButtonFormField<String>(
          value: _accountType,
          decoration: const InputDecoration(
            labelText: 'Tipo de cuenta',
          ),
          items: const [
            DropdownMenuItem(
              value: 'SAVINGS',
              child: Text('Cuenta de Ahorros / Monedero'),
            ),
            DropdownMenuItem(
              value: 'CHECKING',
              child: Text('Cuenta Corriente'),
            ),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _accountType = val);
          },
        ),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: AppColors.error, fontSize: 13)),
        ],

        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Autorizar y Vincular Cuenta',
          icon: Icons.link,
          loading: _submitting,
          onPressed: _submitting ? null : _submitLink,
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      key: const ValueKey('step_success'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '¡${_selectedBank?.tenantName ?? 'Cuenta'} vinculada con éxito!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'La entidad bancaria ya está disponible en tu Dashboard principal y en el selector rápido de cuentas.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Volver al Inicio',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
