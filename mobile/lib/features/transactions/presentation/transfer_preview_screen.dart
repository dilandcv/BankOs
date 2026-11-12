import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class TransferPreviewScreen extends ConsumerWidget {
  const TransferPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Previsualización')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumen de transferencia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 14),
                  _row('Cuenta origen', 'Cuenta Corriente · **** 4821'),
                  _row('Cuenta destino', 'Cuenta de Ahorros · **** 9034'),
                  _row('Monto a enviar', '\$ 250.00 USD'),
                  const Divider(height: 24),
                  _row('Tasa de cambio', '1.00'),
                  _row('Comisión estimada', '\$ 1.50'),
                  _row('Monto a debitar', '\$ 251.50'),
                  _row('Monto a acreditar', '\$ 250.00', highlight: true),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Valores de ejemplo para diseño. La confirmación y cálculos finales se procesarán con la lógica del sistema.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirmar (diseño)',
            icon: Icons.check,
            onPressed: () => context.go('/transactions'),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Volver',
            outlined: true,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                color: highlight ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
