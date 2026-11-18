/// Rutas relativas al base path `/api/v1`.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';

  static const String tenants = '/tenants';
  static const String users = '/users';
  static const String customers = '/customers';

  static const String accounts = '/accounts';
  static const String accountsAll = '/accounts/all';

  static const String transactions = '/transactions';
  static const String deposits = '/transactions/deposits';
  static const String withdrawals = '/transactions/withdrawals';
  static const String transfers = '/transactions/transfers';
  static const String transferPreview = '/transactions/transfers/preview';

  static const String settings = '/settings';
  static const String exchangeRates = '/settings/exchange-rates';
  static const String auditLogs = '/audit-logs';
  static const String webhooks = '/webhooks';
  static const String webhookEvents = '/webhooks/events';

  static String tenantById(String id) => '/tenants/$id';
  static String userById(String id) => '/users/$id';
  static String customerById(String id) => '/customers/$id';
  static String accountById(String id) => '/accounts/$id';
  static String transactionById(String id) => '/transactions/$id';
  static String exchangeRateById(String id) => '/settings/exchange-rates/$id';
  static String auditLogById(String id) => '/audit-logs/$id';
}
