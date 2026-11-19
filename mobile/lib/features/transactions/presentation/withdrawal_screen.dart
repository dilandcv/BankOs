import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/network/idempotency_key.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/accounts/data/account.dart';
import 'package:mobile/features/accounts/data/accounts_providers.dart';
import 'package:mobile/features/transactions/data/transactions_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/utils/money_formatter.dart';
import 'package:mobile/shared/widgets/account_selector.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key, this.initialAccountId});

  final String? initialAccountId;

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _keys = IdempotencyKeyKeeper();

  String? _accountId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _accountId = widget.initialAccountId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit(List<AccountModel> accounts) async {
    final accountId = _accountId;
    if (accountId == null) {
      _showMessage('Selecciona la cuenta origen');
      return;
    }
    final matching = accounts.where((a) => a.id == accountId).toList();
    if (matching.isEmpty) {
      _showMessage('La cuenta seleccionada ya no está disponible');
      return;
    }

    final amount = MoneyFormatter.normalizeInput(_amountController.text);
    if (amount.isEmpty || amount.startsWith('-') || amount == '0.00') {
      _showMessage('Ingresa un monto mayor que cero');
      return;
    }

    final currency = matching.first.currency;
    final description = _descriptionController.text.trim();
    final body = <String, dynamic>{
      'account_id': accountId,
      'amount': amount,
      'currency': currency,
      'description': description,
    };

    setState(() => _loading = true);
    try {
      await ref.read(transactionsRepositoryProvider).withdraw(
            accountId: accountId,
            amount: amount,
            currency: currency,
            description: description,
            idempotencyKey: _keys.nextKey(body),
          );
      ref.read(dataVersionProvider.notifier).state++;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retiro realizado')),
      );
      context.go('/transactions');
    } on ApiException catch (error) {
      _showMessage(error.displayMessage);
    } catch (_) {
      _showMessage('No se pudo completar el retiro');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final accounts = accountsAsync.value ?? const <AccountModel>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Retiro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos del retiro',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (accountsAsync.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (accountsAsync.hasError)
                    Text(
                      'No se pudieron cargar las cuentas: ${accountsAsync.error}',
                      style: const TextStyle(color: AppColors.danger),
                    )
                  else
                    AccountSelector(
                      accounts: accounts,
                      value: _accountId,
                      label: 'Cuenta origen',
                      onChanged: (value) => setState(() => _accountId = value),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: const [
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      hintText: '0.00',
                      helperText: 'Separadores de miles (,) y decimales (.) automáticos',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Motivo del retiro',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirmar retiro',
            icon: Icons.check_circle_outline,
            loading: _loading,
            onPressed: () => _submit(accounts),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Cancelar',
            outlined: true,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
