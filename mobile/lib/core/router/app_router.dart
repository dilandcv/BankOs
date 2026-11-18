import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/features/accounts/presentation/account_detail_screen.dart';
import 'package:mobile/features/accounts/presentation/accounts_screen.dart';
import 'package:mobile/features/admin/presentation/access_denied_screen.dart';
import 'package:mobile/features/admin/presentation/admin_hub_screen.dart';
import 'package:mobile/features/audit/presentation/audit_screen.dart';
import 'package:mobile/features/authentication/presentation/login_screen.dart';
import 'package:mobile/features/customers/presentation/customers_screen.dart';
import 'package:mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mobile/features/profile/presentation/profile_screen.dart';
import 'package:mobile/features/settings/presentation/settings_screen.dart';
import 'package:mobile/features/tenants/presentation/banks_screen.dart';
import 'package:mobile/features/tenants/presentation/tenants_admin_screen.dart';
import 'package:mobile/features/transactions/presentation/deposit_screen.dart';
import 'package:mobile/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:mobile/features/transactions/presentation/transfer_preview_screen.dart';
import 'package:mobile/features/transactions/presentation/transfer_screen.dart';
import 'package:mobile/features/transactions/presentation/transactions_screen.dart';
import 'package:mobile/features/transactions/presentation/withdrawal_screen.dart';
import 'package:mobile/features/users/presentation/users_screen.dart';
import 'package:mobile/features/webhooks/presentation/webhooks_screen.dart';

/// Espejo de los `@PreAuthorize` del backend: si el rol no puede entrar,
/// se redirige a `/forbidden` antes de que el servidor responda 403.
bool canAccessAdminPath(UserSummary user, String path) {
  if (path == '/admin') return true;
  if (path.startsWith('/admin/users')) return user.canViewUsers;
  if (path.startsWith('/admin/customers')) return user.canViewCustomers;
  if (path.startsWith('/admin/settings')) return user.canViewSettings;
  if (path.startsWith('/admin/audit')) return user.canViewAudit;
  if (path.startsWith('/admin/webhooks')) return user.canViewWebhooks;
  if (path.startsWith('/admin/tenants')) return user.canCreateTenant;
  return true;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider).value;
  final isLoggedIn = session != null;

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final location = state.matchedLocation;
      final goingToLogin = location == '/login';

      if (!isLoggedIn && !goingToLogin) return '/login';
      if (isLoggedIn && goingToLogin) return '/dashboard';
      final user = session?.user;
      if (isLoggedIn && location.startsWith('/admin') && user != null) {
        if (!canAccessAdminPath(user, location)) return '/forbidden';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          initialTenantCode:
              state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const AccessDeniedScreen(),
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
            builder: (context, state) =>
                DepositScreen(initialAccountId: state.extra as String?),
          ),
          GoRoute(
            path: 'withdrawal',
            builder: (context, state) =>
                WithdrawalScreen(initialAccountId: state.extra as String?),
          ),
          GoRoute(
            path: 'transfer',
            builder: (context, state) =>
                TransferScreen(initialAccountId: state.extra as String?),
            routes: [
              GoRoute(
                path: 'preview',
                builder: (context, state) => const TransferPreviewScreen(),
              ),
            ],
          ),
          // Se declara al final para que no capture 'deposit'/'transfer'.
          GoRoute(
            path: ':id',
            builder: (context, state) => TransactionDetailScreen(
              transactionId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/banks',
        builder: (context, state) => const BanksScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHubScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: '/admin/customers',
        builder: (context, state) => const CustomersScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/admin/audit',
        builder: (context, state) => const AuditScreen(),
      ),
      GoRoute(
        path: '/admin/webhooks',
        builder: (context, state) => const WebhooksScreen(),
      ),
      GoRoute(
        path: '/admin/tenants',
        builder: (context, state) => const TenantsAdminScreen(),
      ),
    ],
  );
});
