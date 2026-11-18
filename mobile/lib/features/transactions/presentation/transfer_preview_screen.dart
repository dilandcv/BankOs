import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/accounts/data/accounts_providers.dart';
import 'package:mobile/features/transactions/data/transaction.dart';
import 'package:mobile/features/transactions/data/transactions_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/utils/money_formatter.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class TransferPreviewScreen extends ConsumerStatefulWidget {
  const TransferPreviewScreen({super.key});

  @override
  ConsumerState<TransferPreviewScreen> createState() =>
      _TransferPreviewScreenState();
}

class _TransferPreviewScreenState extends ConsumerState<TransferPreviewScreen> {
  bool _confirming = false;

  Future<void> _confirm(TransferDraft draft) async {
    setState(() => _confirming = true);
    try {
      final transaction =
          await ref.read(transactionsRepositoryProvider).transfer(draft);
      ref.read(dataVersionProvider.notifier).state++;
      if (!mounted) return;
      await _showReceipt(transaction);
      if (!mounted) return;
      context.go('/transactions');
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.displayMessage)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo completar la transferencia')),
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _showReceipt(TransactionModel transaction) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Transferencia completada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${transaction.id}'),
            const SizedBox(height: 6),
            Text(
              'Monto: ${MoneyFormatter.format(transaction.amount, currency: transaction.currency)}',
            ),
            Text(
              'Comisión: ${MoneyFormatter.format(transaction.fee, currency: transaction.currency)}',
            ),
            Text('Estado: ${transaction.status}'),
            const SizedBox(height: 8),
            Text(
              'Correlación: ${transaction.correlationId}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewAsync = ref.watch(transferPreviewProvider);
    final draft = ref.watch(selectedTransferDraftProvider);
    final accounts = ref.watch(accountsProvider).value ?? const [];

    String accountLabel(String id) {
      final match = accounts.where((account) => account.id == id).toList();
      if (match.isEmpty) return id;
      return '${match.first.displayName} · ${match.first.maskedNumber}';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Previsualización')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (previewAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (previewAsync.hasError)
            Text(
              'No se pudo calcular la transferencia: ${previewAsync.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de transferencia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (draft != null) ...[
                      _row('Cuenta origen', accountLabel(draft.sourceAccountId)),
                      _row('Cuenta destino', accountLabel(draft.targetAccountId)),
                    ],
                    _row(
                      'Monto a enviar',
                      MoneyFormatter.format(
                        previewAsync.value!.amount,
                        currency: previewAsync.value!.sourceCurrency,
                      ),
                    ),
                    const Divider(height: 24),
                    _row('Tasa de cambio', previewAsync.value!.exchangeRate),
                    _row(
                      'Comisión estimada',
                      MoneyFormatter.format(
                        previewAsync.value!.fee,
                        currency: previewAsync.value!.sourceCurrency,
                      ),
                    ),
                    _row(
                      'Monto a debitar',
                      MoneyFormatter.format(
                        previewAsync.value!.debitAmount,
                        currency: previewAsync.value!.sourceCurrency,
                      ),
                    ),
                    _row(
                      'Monto a acreditar',
                      MoneyFormatter.format(
                        previewAsync.value!.creditAmount,
                        currency: previewAsync.value!.targetCurrency,
                      ),
                      highlight: true,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Cálculos realizados por el backend. La confirmación usa la '
                        'misma llave de idempotencia aunque repitas el envío.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirmar transferencia',
            icon: Icons.check,
            loading: _confirming,
            onPressed: draft == null || previewAsync.value == null
                ? null
                : () => _confirm(draft),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Volver',
            outlined: true,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                color: highlight
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
