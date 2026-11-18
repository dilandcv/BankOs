import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/constants/app_colors.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showBottomNav = false,
    this.currentIndex = 0,
  });

  final String title;
  final Widget child;
  final bool showBottomNav;
  final int currentIndex;

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/accounts');
        break;
      case 2:
        context.go('/transactions');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: showBottomNav
          ? BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (i) => _onNavTap(context, i),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: AppColors.textSecondary,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Inicio'),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Cuentas'),
                BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Movimientos'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
              ],
            )
          : null,
    );
  }
}
