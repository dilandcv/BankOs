import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.account_balance, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'BankOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Accede a tu banca digital',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Iniciar sesión',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            label: 'Ingresar',
                            icon: Icons.login,
                            onPressed: () => context.go('/dashboard'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => context.go('/dashboard'),
                            icon: const Icon(Icons.fingerprint, color: AppColors.primary),
                            label: const Text('Ingresar con biometría'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Entorno seguro · Multi-institución',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
