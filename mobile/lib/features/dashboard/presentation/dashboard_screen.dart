import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/constants/mock_data.dart';
import 'package:mobile/shared/widgets/account_card.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/balance_card.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Inicio',
      showBottomNav: true,
      currentIndex: 0,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Hola, ${MockData.userName}',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(MockData.tenantName, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          const BalanceCard(
            title: 'Saldo total disponible',
            amount: MockData.totalBalance,
            subtitle: 'Todas tus cuentas activas',
          ),
          const SizedBox(height: 20),
          const Text('Accesos rápidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
              const Text('Mis cuentas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              TextButton(onPressed: () => context.go('/accounts'), child: const Text('Ver todas')),
            ],
          ),
          ...MockData.accounts.take(2).map((a) => AccountCard(
                name: a['name']!,
                number: a['number']!,
                balance: a['balance']!,
                currency: a['currency']!,
                status: a['status']!,
                onTap: () => context.go('/accounts/${a['id']}'),
              )),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Últimos movimientos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              TextButton(onPressed: () => context.go('/transactions'), child: const Text('Ver historial')),
            ],
          ),
          ...MockData.transactions.take(3).map((t) => TransactionTile(
                title: t['title']!,
                subtitle: t['subtitle']!,
                amount: t['amount']!,
                isIncoming: t['type'] == 'in',
              )),
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

class _QuickAction extends ConsumerWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
