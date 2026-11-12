import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/constants/mock_data.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/primary_button.dart';
import 'package:mobile/shared/widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Movimientos',
      showBottomNav: true,
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Operaciones',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text('Realiza operaciones y consulta tu historial', style: TextStyle(color: AppColors.textSecondary)),
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
          const Text('Historial de movimientos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text('Todos'), backgroundColor: AppColors.surfaceMuted),
              Chip(label: Text('Ingresos')),
              Chip(label: Text('Egresos')),
            ],
          ),
          const SizedBox(height: 12),
          ...MockData.transactions.map((t) => TransactionTile(
                title: t['title']!,
                subtitle: t['subtitle']!,
                amount: t['amount']!,
                isIncoming: t['type'] == 'in',
              )),
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

class _OpCard extends ConsumerWidget {
  const _OpCard({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
