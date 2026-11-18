class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.accountId,
    required this.direction,
    required this.amount,
    required this.currency,
    required this.createdAt,
  });

  final String id;
  final String accountId;
  final String direction;
  final String amount;
  final String currency;
  final String createdAt;

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      id: (json['id'] as String?) ?? '',
      accountId: (json['account_id'] as String?) ?? '',
      direction: (json['direction'] as String?) ?? '',
      amount: (json['amount'] as String?) ?? '0.0000',
      currency: (json['currency'] as String?) ?? '',
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }

  bool get isCredit => direction.toUpperCase() == 'CREDIT';
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    required this.fee,
    required this.exchangeRate,
    required this.sourceAccountId,
    required this.destinationAccountId,
    required this.description,
    required this.correlationId,
    required this.createdAt,
    required this.entries,
  });

  final String id;
  final String type;
  final String status;
  final String amount;
  final String currency;
  final String fee;
  final String exchangeRate;
  final String sourceAccountId;
  final String destinationAccountId;
  final String description;
  final String correlationId;
  final String createdAt;
  final List<TransactionEntry> entries;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawEntries = (json['entries'] as List<dynamic>?) ?? const <dynamic>[];
    return TransactionModel(
      id: (json['id'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      amount: (json['amount'] as String?) ?? '0.0000',
      currency: (json['currency'] as String?) ?? '',
      fee: (json['fee'] as String?) ?? '0.0000',
      exchangeRate: (json['exchange_rate'] as String?) ?? '1.00000000',
      sourceAccountId: (json['source_account_id'] as String?) ?? '',
      destinationAccountId: (json['destination_account_id'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      correlationId: (json['correlation_id'] as String?) ?? '',
      createdAt: (json['created_at'] as String?) ?? '',
      entries: rawEntries
          .map((entry) =>
              TransactionEntry.fromJson((entry as Map).cast<String, dynamic>()))
          .toList(growable: false),
    );
  }

  String get displayTitle => switch (type.toUpperCase()) {
        'DEPOSIT' => 'Depósito recibido',
        'WITHDRAWAL' => 'Retiro realizado',
        'TRANSFER' => 'Transferencia enviada',
        _ => type,
      };

  String get displaySubtitle {
    final note = description.trim().isEmpty ? type.toLowerCase() : description.trim();
    return '$note · $shortDate';
  }

  String get shortDate {
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) return createdAt;
    final local = parsed.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  bool isIncomingFor(String? accountId) {
    if (accountId == null || accountId.isEmpty) {
      return type.toUpperCase() == 'DEPOSIT';
    }
    if (destinationAccountId == accountId) return true;
    if (sourceAccountId == accountId) return false;
    return type.toUpperCase() == 'DEPOSIT';
  }
}

class TransferPreview {
  const TransferPreview({
    required this.sourceAccountId,
    required this.targetAccountId,
    required this.amount,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.exchangeRate,
    required this.fee,
    required this.debitAmount,
    required this.creditAmount,
  });

  final String sourceAccountId;
  final String targetAccountId;
  final String amount;
  final String sourceCurrency;
  final String targetCurrency;
  final String exchangeRate;
  final String fee;
  final String debitAmount;
  final String creditAmount;

  factory TransferPreview.fromJson(Map<String, dynamic> json) {
    return TransferPreview(
      sourceAccountId: (json['source_account_id'] as String?) ?? '',
      targetAccountId: (json['target_account_id'] as String?) ?? '',
      amount: (json['amount'] as String?) ?? '0.0000',
      sourceCurrency: (json['source_currency'] as String?) ?? '',
      targetCurrency: (json['target_currency'] as String?) ?? '',
      exchangeRate: (json['exchange_rate'] as String?) ?? '1.00000000',
      fee: (json['fee'] as String?) ?? '0.0000',
      debitAmount: (json['debit_amount'] as String?) ?? '0.0000',
      creditAmount: (json['credit_amount'] as String?) ?? '0.0000',
    );
  }
}

/// Datos que viajan de la pantalla de transferencia a la previsualización.
class TransferDraft {
  const TransferDraft({
    required this.sourceAccountId,
    required this.targetAccountId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.idempotencyKey,
  });

  final String sourceAccountId;
  final String targetAccountId;
  final String amount;
  final String currency;
  final String description;
  final String idempotencyKey;
}
