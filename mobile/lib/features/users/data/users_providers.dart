import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/users/data/user.dart';
import 'package:mobile/features/users/data/users_repository.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.watch(apiClientProvider));
});

final usersProvider = FutureProvider<PageResponse<UserModel>>((ref) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(usersRepositoryProvider).list();
});
