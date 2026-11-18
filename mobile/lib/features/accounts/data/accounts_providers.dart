import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/accounts/data/account.dart';
import 'package:mobile/features/accounts/data/accounts_repository.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(ref.watch(apiClientProvider));
});

/// Se recarga cuando cambia la sesión (login, cambio de banco o logout).
final accountsProvider = FutureProvider<List<AccountModel>>((ref) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(accountsRepositoryProvider).listAll();
});

final accountByIdProvider =
    FutureProvider.family<AccountModel, String>((ref, id) async {
  ref.watch(sessionControllerProvider);
  return ref.read(accountsRepositoryProvider).byId(id);
});
