import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/audit/data/audit_log.dart';
import 'package:mobile/features/audit/data/audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository(ref.watch(apiClientProvider));
});

final auditLogsProvider = FutureProvider<PageResponse<AuditLogModel>>((ref) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(auditRepositoryProvider).list();
});
