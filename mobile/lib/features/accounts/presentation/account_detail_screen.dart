import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/utils/input_validators.dart';
import 'package:mobile/features/accounts/data/accounts_providers.dart';
import 'package:mobile/features/transactions/data/transactions_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/utils/money_formatter.dart';
import 'package:mobile/shared/widgets/balance_card.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/transaction_tile.dart';

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!InputValidators.isUuid(accountId)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cuenta')),
        body: const Center(
          child: Text('Identificador de cuenta no válido'),
        ),
      );
    }

    final accountAsync = ref.watch(accountByIdProvider(accountId));
    final historyAsync = ref.watch(accountTransactionsProvider(accountId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(accountAsync.value?.displayName ?? 'Cuenta'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (accountAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (accountAsync.hasError)
            Text(
              'No se pudo cargar la cuenta: ${accountAsync.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else
            BalanceCard(
              title: '${accountAsync.value!.displayName} · '
                  '${accountAsync.value!.maskedNumber}',
              amount: MoneyFormatter.format(
                accountAsync.value!.balance,
                currency: accountAsync.value!.currency,
              ),
              subtitle: 'Moneda ${accountAsync.value!.currency} · '
                  '${accountAsync.value!.isActive ? 'Activa' : accountAsync.value!.status}',
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Depositar',
                  icon: Icons.south_west,
                  onPressed: () => context.go(
                    '/transactions/deposit',
                    extra: accountAsync.value?.id,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: 'Transferir',
                  icon: Icons.swap_horiz,
                  outlined: true,
                  onPressed: () => context.go(
                    '/transactions/transfer',
                    extra: accountAsync.value?.id,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Historial de la cuenta',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (historyAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (historyAsync.value?.items.isEmpty ?? true)
            const Text(
              'Sin movimientos para esta cuenta',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...historyAsync.value!.items.map(
              (transaction) => TransactionTile(
                title: transaction.displayTitle,
                subtitle: transaction.displaySubtitle,
                amount: MoneyFormatter.format(
                  transaction.amount,
                  currency: transaction.currency,
                  signed: transaction.isIncomingFor(accountId),
                ),
                isIncoming: transaction.isIncomingFor(accountId),
                onTap: () => context.go('/transactions/${transaction.id}'),
              ),
            ),
        ],
      ),
    );
  }
}
