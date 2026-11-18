import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/transactions/data/transaction.dart';
import 'package:mobile/features/transactions/data/transactions_repository.dart';

class TransactionFilter {
  const TransactionFilter({
    this.page = 0,
    this.size = 10,
    this.accountId,
    this.type,
    this.from,
    this.to,
  });

  final int page;
  final int size;
  final String? accountId;
  final String? type;
  final DateTime? from;
  final DateTime? to;

  TransactionFilter copyWith({
    int? page,
    int? size,
    String? accountId,
    String? type,
    DateTime? from,
    DateTime? to,
    bool clearAccount = false,
    bool clearType = false,
  }) {
    return TransactionFilter(
      page: page ?? this.page,
      size: size ?? this.size,
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      type: clearType ? null : (type ?? this.type),
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(ref.watch(apiClientProvider));
});

final transactionFilterProvider =
    StateProvider<TransactionFilter>((ref) => const TransactionFilter());

final transactionsProvider =
    FutureProvider<PageResponse<TransactionModel>>((ref) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  final filter = ref.watch(transactionFilterProvider);
  return ref.read(transactionsRepositoryProvider).history(
        page: filter.page,
        size: filter.size,
        accountId: filter.accountId,
        type: filter.type,
        from: filter.from,
        to: filter.to,
      );
});

/// Borrador seleccionado en la pantalla de transferencia.
final selectedTransferDraftProvider =
    StateProvider<TransferDraft?>((ref) => null);

final transferPreviewProvider = FutureProvider<TransferPreview>((ref) async {
  final draft = ref.watch(selectedTransferDraftProvider);
  if (draft == null) throw StateError('No hay una transferencia en curso');
  return ref.read(transactionsRepositoryProvider).preview(draft);
});

/// Detalle real de una transacción (`GET /transactions/{id}`).
final transactionByIdProvider =
    FutureProvider.family<TransactionModel, String>((ref, id) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(transactionsRepositoryProvider).byId(id);
});

final accountTransactionsProvider = FutureProvider.family<
    PageResponse<TransactionModel>, String>((ref, accountId) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(transactionsRepositoryProvider).history(
        accountId: accountId,
        size: 10,
      );
});
