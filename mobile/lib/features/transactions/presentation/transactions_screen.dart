import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/accounts/data/accounts_providers.dart';
import 'package:mobile/features/transactions/data/transactions_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/utils/money_formatter.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);
    final historyAsync = ref.watch(transactionsProvider);
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final page = historyAsync.value;

    void setType(String? type) {
      ref.read(transactionFilterProvider.notifier).state =
          filter.copyWith(page: 0, type: type, clearType: type == null);
    }

    return AppScaffold(
      title: 'Movimientos',
      showBottomNav: true,
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Operaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Realiza operaciones y consulta tu historial',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OpCard(
                  icon: Icons.south_west,
                  title: 'Depósito',
                  onTap: () => context.go('/transactions/deposit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OpCard(
                  icon: Icons.north_east,
                  title: 'Retiro',
                  onTap: () => context.go('/transactions/withdrawal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OpCard(
                  icon: Icons.swap_horiz,
                  title: 'Transferir',
                  onTap: () => context.go('/transactions/transfer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Historial de movimientos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(label: 'Todos', selected: filter.type == null, onTap: () => setType(null)),
              _FilterChip(label: 'Depósitos', selected: filter.type == 'DEPOSIT', onTap: () => setType('DEPOSIT')),
              _FilterChip(label: 'Retiros', selected: filter.type == 'WITHDRAWAL', onTap: () => setType('WITHDRAWAL')),
              _FilterChip(label: 'Transferencias', selected: filter.type == 'TRANSFER', onTap: () => setType('TRANSFER')),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String?>(
            initialValue: filter.accountId,
            decoration: const InputDecoration(
              labelText: 'Filtrar por cuenta',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
            ),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Todas las cuentas')),
              ...accounts.map(
                (account) => DropdownMenuItem<String?>(
                  value: account.id,
                  child: Text('${account.displayName} · ${account.maskedNumber}'),
                ),
              ),
            ],
            onChanged: (value) {
              ref.read(transactionFilterProvider.notifier).state =
                  filter.copyWith(
                page: 0,
                accountId: value,
                clearAccount: value == null,
              );
            },
          ),
          const SizedBox(height: 12),
          if (historyAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (historyAsync.hasError)
            Text(
              'No se pudo cargar el historial: ${historyAsync.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else if (page?.items.isEmpty ?? true)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Sin movimientos para los filtros seleccionados',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...page!.items.map(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Página ${(page?.page ?? 0) + 1} de ${(page?.totalPages ?? 0) == 0 ? 1 : page!.totalPages}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: filter.page == 0
                        ? null
                        : () => ref.read(transactionFilterProvider.notifier).state =
                            filter.copyWith(page: filter.page - 1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: page != null && page.page + 1 >= page.totalPages
                        ? null
                        : () => ref.read(transactionFilterProvider.notifier).state =
                            filter.copyWith(page: filter.page + 1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Nueva transferencia',
            icon: Icons.swap_horiz,
            onPressed: () => context.go('/transactions/transfer'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.surfaceMuted,
    );
  }
}

class _OpCard extends StatelessWidget {
  const _OpCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
