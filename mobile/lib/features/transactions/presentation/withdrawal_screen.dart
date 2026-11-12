import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class WithdrawalScreen extends ConsumerWidget {
  const WithdrawalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Retiro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Datos del retiro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  SizedBox(height: 14),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Cuenta origen',
                      hintText: 'Selecciona una cuenta',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Moneda',
                      hintText: 'USD',
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Motivo del retiro',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Continuar',
            icon: Icons.check_circle_outline,
            onPressed: () => context.go('/transactions'),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Cancelar',
            outlined: true,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
