import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/constants/app_colors.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncoming,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isIncoming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = isIncoming ? AppColors.success : AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceMuted,
            child: Icon(
              isIncoming ? Icons.south_west : Icons.north_east,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
