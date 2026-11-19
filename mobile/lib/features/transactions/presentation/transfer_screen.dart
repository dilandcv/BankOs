import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile/features/accounts/data/account.dart';
import 'package:mobile/features/accounts/data/accounts_providers.dart';
import 'package:mobile/features/transactions/data/transaction.dart';
import 'package:mobile/features/transactions/data/transactions_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/utils/money_formatter.dart';
import 'package:mobile/shared/widgets/account_selector.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key, this.initialAccountId});

  final String? initialAccountId;

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _idempotencyKey = const Uuid().v4();

  String? _sourceId;
  String? _targetId;

  @override
  void initState() {
    super.initState();
    _sourceId = widget.initialAccountId;
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

  void _goToPreview(List<AccountModel> accounts) {
    if (_sourceId == null || _targetId == null) {
      _showMessage('Selecciona la cuenta origen y la destino');
      return;
    }
    if (_sourceId == _targetId) {
      _showMessage('La cuenta origen y destino deben ser distintas');
      return;
    }
    final source = accounts.where((a) => a.id == _sourceId).toList();
    if (source.isEmpty) {
      _showMessage('La cuenta origen ya no está disponible');
      return;
    }

    final amount = MoneyFormatter.normalizeInput(_amountController.text);
    if (amount.isEmpty || amount.startsWith('-') || amount == '0.00') {
      _showMessage('Ingresa un monto mayor que cero');
      return;
    }

    final draft = TransferDraft(
      sourceAccountId: _sourceId!,
      targetAccountId: _targetId!,
      amount: amount,
      currency: source.first.currency,
      description: _descriptionController.text.trim(),
      idempotencyKey: _idempotencyKey,
    );

    ref.read(selectedTransferDraftProvider.notifier).state = draft;
    ref.invalidate(transferPreviewProvider);
    context.go('/transactions/transfer/preview');
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final accounts = accountsAsync.value ?? const <AccountModel>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Transferencia')),
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
                    'Datos de la transferencia',
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
                  else ...[
                    AccountSelector(
                      accounts: accounts,
                      value: _sourceId,
                      label: 'Cuenta origen',
                      onChanged: (value) => setState(() => _sourceId = value),
                    ),
                    const SizedBox(height: 12),
                    AccountSelector(
                      accounts: accounts,
                      value: _targetId,
                      label: 'Cuenta destino',
                      onChanged: (value) => setState(() => _targetId = value),
                    ),
                  ],
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
                      hintText: 'Concepto de transferencia',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Ver previsualización',
            icon: Icons.visibility_outlined,
            onPressed: () => _goToPreview(accounts),
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
