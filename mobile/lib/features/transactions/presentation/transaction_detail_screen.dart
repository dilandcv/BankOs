import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/utils/input_validators.dart';
import 'package:mobile/features/transactions/data/transaction.dart';
import 'package:mobile/features/transactions/data/transactions_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/utils/money_formatter.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';

/// Detalle de una transacción con sus asientos contables.
class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!InputValidators.isUuid(transactionId)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Movimiento')),
        body: const Center(child: Text('Identificador de movimiento no válido')),
      );
    }

    final async = ref.watch(transactionByIdProvider(transactionId));

    return AppScaffold(
      title: 'Detalle del movimiento',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (async.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (async.hasError)
            Text(
              'No se pudo cargar el movimiento: ${async.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else
            _DetailContent(transaction: async.value!),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final incoming = transaction.isIncomingFor(null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.surfaceMuted,
                  child: Icon(
                    incoming ? Icons.south_west : Icons.north_east,
                    color: incoming
                        ? AppColors.success
                        : Theme.of(context).colorScheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  transaction.displayTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  MoneyFormatter.format(
                    transaction.amount,
                    currency: transaction.currency,
                    signed: incoming,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: incoming ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    transaction.status,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información de la operación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _row('ID', transaction.id),
                _row('Tipo', transaction.type),
                _row('Fecha', _fullDate(transaction.createdAt)),
                _row('Descripción', transaction.description),
                _row(
                  'Comisión',
                  MoneyFormatter.format(
                    transaction.fee,
                    currency: transaction.currency,
                  ),
                ),
                _row('Tasa de cambio', transaction.exchangeRate),
                _row('Correlación', transaction.correlationId),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asientos contables',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (transaction.entries.isEmpty)
                  const Text(
                    'Esta operación no registró asientos detallados',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  ...transaction.entries.map(_entryRow),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryRow(TransactionEntry entry) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.direction,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                entry.accountId,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            MoneyFormatter.format(entry.amount, currency: entry.currency),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: entry.isCredit ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _fullDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? raw : parsed.toLocal().toString();
  }
}
