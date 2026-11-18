import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/utils/input_validators.dart';
import 'package:mobile/features/transactions/data/transaction.dart';

class TransactionsRepository {
  TransactionsRepository(this._api);

  final ApiClient _api;

  Future<PageResponse<TransactionModel>> history({
    int page = 0,
    int size = 10,
    String? accountId,
    String? type,
    DateTime? from,
    DateTime? to,
  }) async {
    final query = <String, dynamic>{'page': page, 'size': size};
    if (accountId != null && accountId.trim().isNotEmpty) {
      query['accountId'] =
          InputValidators.requireUuid(accountId, field: 'cuenta');
    }
    if (type != null && type.trim().isNotEmpty) query['type'] = type;
    if (from != null) query['from'] = from.toUtc().toIso8601String();
    if (to != null) query['to'] = to.toUtc().toIso8601String();

    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.transactions,
      queryParameters: query,
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );

    return PageResponse<TransactionModel>.fromJson(
      envelope.data!,
      (item) => TransactionModel.fromJson((item as Map).cast<String, dynamic>()),
    );
  }

  Future<TransactionModel> byId(String id) async {
    final validId = InputValidators.requireUuid(id, field: 'transacción');
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.transactionById(validId),
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return TransactionModel.fromJson(envelope.data!);
  }

  Future<TransactionModel> deposit({
    required String accountId,
    required String amount,
    required String currency,
    String? description,
    required String idempotencyKey,
  }) async {
    final envelope = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.deposits,
      headers: <String, dynamic>{'Idempotency-Key': idempotencyKey},
      data: <String, dynamic>{
        'account_id': InputValidators.requireUuid(accountId, field: 'cuenta'),
        'amount': InputValidators.requireText(amount, field: 'monto'),
        'currency': InputValidators.requireText(currency, field: 'moneda').toUpperCase(),
        'description': description?.trim() ?? '',
      },
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return TransactionModel.fromJson(envelope.data!);
  }

  Future<TransactionModel> withdraw({
    required String accountId,
    required String amount,
    required String currency,
    String? description,
    required String idempotencyKey,
  }) async {
    final envelope = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.withdrawals,
      headers: <String, dynamic>{'Idempotency-Key': idempotencyKey},
      data: <String, dynamic>{
        'account_id': InputValidators.requireUuid(accountId, field: 'cuenta'),
        'amount': InputValidators.requireText(amount, field: 'monto'),
        'currency': InputValidators.requireText(currency, field: 'moneda').toUpperCase(),
        'description': description?.trim() ?? '',
      },
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return TransactionModel.fromJson(envelope.data!);
  }

  Future<TransferPreview> preview(TransferDraft draft) async {
    final envelope = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.transferPreview,
      data: <String, dynamic>{
        'source_account_id':
            InputValidators.requireUuid(draft.sourceAccountId, field: 'cuenta origen'),
        'target_account_id':
            InputValidators.requireUuid(draft.targetAccountId, field: 'cuenta destino'),
        'amount': InputValidators.requireText(draft.amount, field: 'monto'),
        'currency': draft.currency.toUpperCase(),
      },
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return TransferPreview.fromJson(envelope.data!);
  }

  Future<TransactionModel> transfer(TransferDraft draft) async {
    final envelope = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.transfers,
      headers: <String, dynamic>{'Idempotency-Key': draft.idempotencyKey},
      data: <String, dynamic>{
        'source_account_id':
            InputValidators.requireUuid(draft.sourceAccountId, field: 'cuenta origen'),
        'target_account_id':
            InputValidators.requireUuid(draft.targetAccountId, field: 'cuenta destino'),
        'amount': InputValidators.requireText(draft.amount, field: 'monto'),
        'currency': draft.currency.toUpperCase(),
        'description': draft.description.trim(),
      },
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return TransactionModel.fromJson(envelope.data!);
  }
}
