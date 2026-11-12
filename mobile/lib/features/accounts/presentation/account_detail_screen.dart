import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/constants/mock_data.dart';
import 'package:mobile/shared/widgets/balance_card.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/transaction_tile.dart';

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = MockData.accounts.firstWhere(
      (a) => a['id'] == accountId,
      orElse: () => MockData.accounts.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: Text(account['name']!),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BalanceCard(
            title: '${account['name']} · ${account['number']}',
            amount: account['balance']!,
            subtitle: 'Moneda ${account['currency']} · ${account['status']}',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Depositar',
                  icon: Icons.south_west,
                  onPressed: () => context.go('/transactions/deposit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: 'Transferir',
                  icon: Icons.swap_horiz,
                  outlined: true,
                  onPressed: () => context.go('/transactions/transfer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Historial de la cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ...MockData.transactions.map((t) => TransactionTile(
                title: t['title']!,
                subtitle: t['subtitle']!,
                amount: t['amount']!,
                isIncoming: t['type'] == 'in',
              )),
        ],
      ),
    );
  }
}
