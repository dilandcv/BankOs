class AccountModel {
  const AccountModel({
    required this.id,
    required this.customerId,
    required this.accountNumber,
    required this.currency,
    required this.balance,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String customerId;
  final String accountNumber;
  final String currency;
  final String balance;
  final String status;
  final String createdAt;

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: (json['id'] as String?) ?? '',
      customerId: (json['customer_id'] as String?) ?? '',
      accountNumber: (json['account_number'] as String?) ?? '',
      currency: (json['currency'] as String?) ?? '',
      balance: (json['balance'] as String?) ?? '0.0000',
      status: (json['status'] as String?) ?? '',
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }

  String get displayName => 'Cuenta $currency';

  String get maskedNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '•••• ${accountNumber.substring(accountNumber.length - 4)}';
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
