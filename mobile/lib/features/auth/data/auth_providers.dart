import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/session/auth_session.dart';

/// Todas las sesiones guardadas por banco, ordenadas por código.
final savedSessionsProvider = FutureProvider<List<AuthSession>>((ref) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(authRepositoryProvider).getSessions();
});
