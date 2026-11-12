import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/accounts/presentation/account_detail_screen.dart';
import 'package:mobile/features/accounts/presentation/accounts_screen.dart';
import 'package:mobile/features/authentication/presentation/login_screen.dart';
import 'package:mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mobile/features/profile/presentation/profile_screen.dart';
import 'package:mobile/features/transactions/presentation/deposit_screen.dart';
import 'package:mobile/features/transactions/presentation/transfer_preview_screen.dart';
import 'package:mobile/features/transactions/presentation/transfer_screen.dart';
import 'package:mobile/features/transactions/presentation/transactions_screen.dart';
import 'package:mobile/features/transactions/presentation/withdrawal_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => AccountDetailScreen(
              accountId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionsScreen(),
        routes: [
          GoRoute(
            path: 'deposit',
            builder: (context, state) => const DepositScreen(),
          ),
          GoRoute(
            path: 'withdrawal',
            builder: (context, state) => const WithdrawalScreen(),
          ),
          GoRoute(
            path: 'transfer',
            builder: (context, state) => const TransferScreen(),
            routes: [
              GoRoute(
                path: 'preview',
                builder: (context, state) => const TransferPreviewScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
