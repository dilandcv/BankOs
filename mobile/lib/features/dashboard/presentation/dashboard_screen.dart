import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/accounts/data/accounts_providers.dart';
import 'package:mobile/features/transactions/data/transactions_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/utils/money_formatter.dart';
import 'package:mobile/shared/widgets/account_card.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/balance_card.dart';
import 'package:mobile/shared/widgets/bank_switcher_bottom_sheet.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).value;
    final accountsAsync = ref.watch(accountsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final accounts = accountsAsync.value ?? const [];
    final transactions = transactionsAsync.value?.items ?? const [];

    final currencies = accounts.map((account) => account.currency).toSet().toList()
      ..sort();

    return AppScaffold(
      title: 'Inicio',
      showBottomNav: true,
      currentIndex: 0,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Entidad activa: ${session?.tenant.name ?? 'Banco'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => BankSwitcherBottomSheet.show(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Cambiar',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Text(
            'Hola, ${session?.user.fullName ?? 'usuario'}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            session?.tenant.name ?? '',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (accountsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (accountsAsync.hasError)
            _ErrorBox(message: 'No se pudieron cargar las cuentas: ${accountsAsync.error}')
          else
            ...currencies.map((currency) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BalanceCard(
                    title: 'Saldo disponible en $currency',
                    amount: MoneyFormatter.format(
                      MoneyFormatter.sum(
                        accounts
                            .where((account) => account.currency == currency)
                            .map((account) => account.balance),
                      ),
                      currency: currency,
                    ),
                    subtitle: '${accounts.where((a) => a.currency == currency).length} '
                        'cuenta(s) activa(s)',
                  ),
                )),
          const SizedBox(height: 10),
          const Text(
            'Accesos rápidos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.south_west,
                  label: 'Depositar',
                  onTap: () => context.go('/transactions/deposit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.north_east,
                  label: 'Retirar',
                  onTap: () => context.go('/transactions/withdrawal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.swap_horiz,
                  label: 'Transferir',
                  onTap: () => context.go('/transactions/transfer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis cuentas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/accounts'),
                child: const Text('Ver todas'),
              ),
            ],
          ),
          if (accounts.isEmpty)
            const _EmptyBox(message: 'Todavía no hay cuentas en este banco')
          else
            ...accounts.take(2).map(
                  (account) => AccountCard(
                    name: account.displayName,
                    number: account.maskedNumber,
                    balance: MoneyFormatter.format(account.balance,
                        currency: account.currency),
                    currency: account.currency,
                    status: account.isActive ? 'Activa' : account.status,
                    onTap: () => context.go('/accounts/${account.id}'),
                  ),
                ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimos movimientos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/transactions'),
                child: const Text('Ver historial'),
              ),
            ],
          ),
          if (transactionsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (transactions.isEmpty)
            const _EmptyBox(message: 'Aún no hay movimientos')
          else
            ...transactions.take(3).map(
                  (transaction) => TransactionTile(
                    title: transaction.displayTitle,
                    subtitle: transaction.displaySubtitle,
                    amount: MoneyFormatter.format(
                      transaction.amount,
                      currency: transaction.currency,
                      signed: transaction.type.toUpperCase() == 'DEPOSIT',
                    ),
                    isIncoming: transaction.isIncomingFor(null),
                    onTap: () => context.go('/transactions/${transaction.id}'),
                  ),
                ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Ir a movimientos',
            outlined: true,
            icon: Icons.receipt_long,
            onPressed: () => context.go('/transactions'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.danger)),
    );
  }
}
