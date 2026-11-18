import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/tenants/data/tenant.dart';
import 'package:mobile/features/tenants/data/tenants_repository.dart';

final tenantsRepositoryProvider = Provider<TenantsRepository>((ref) {
  return TenantsRepository(ref.watch(apiClientProvider));
});

/// Lista remota de instituciones. Roles sin permiso ven solo las sesiones
/// guardadas en el dispositivo, sin error visible.
final tenantsProvider = FutureProvider<List<TenantModel>>((ref) async {
  ref.watch(sessionControllerProvider);
  try {
    return await ref.read(tenantsRepositoryProvider).list();
  } on ApiException catch (error) {
    if (error.isForbidden) return const <TenantModel>[];
    rethrow;
  }
});
