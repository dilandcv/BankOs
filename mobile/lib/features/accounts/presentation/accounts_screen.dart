import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/constants/mock_data.dart';
import 'package:mobile/shared/widgets/account_card.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Cuentas',
      showBottomNav: true,
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tus cuentas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text('Consulta saldos y detalles por cuenta', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ...MockData.accounts.map((a) => AccountCard(
                name: a['name']!,
                number: a['number']!,
                balance: a['balance']!,
                currency: a['currency']!,
                status: a['status']!,
                onTap: () => context.go('/accounts/${a['id']}'),
              )),
        ],
      ),
    );
  }
}
