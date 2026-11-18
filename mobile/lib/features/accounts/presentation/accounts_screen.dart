import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/accounts/data/accounts_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/utils/money_formatter.dart';
import 'package:mobile/shared/widgets/account_card.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return AppScaffold(
      title: 'Cuentas',
      showBottomNav: true,
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tus cuentas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Saldos en tiempo real del banco activo',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (accountsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (accountsAsync.hasError)
            Text(
              'No se pudieron cargar las cuentas: ${accountsAsync.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else if (accountsAsync.value!.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Este banco todavía no tiene cuentas',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...accountsAsync.value!.map(
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
        ],
      ),
    );
  }
}
