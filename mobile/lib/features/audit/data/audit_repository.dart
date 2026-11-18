import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/utils/input_validators.dart';
import 'package:mobile/features/audit/data/audit_log.dart';

class AuditRepository {
  AuditRepository(this._api);

  final ApiClient _api;

  Future<PageResponse<AuditLogModel>> list({int page = 0, int size = 20}) async {
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.auditLogs,
      queryParameters: <String, dynamic>{'page': page, 'size': size},
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return PageResponse<AuditLogModel>.fromJson(
      envelope.data!,
      (item) => AuditLogModel.fromJson((item as Map).cast<String, dynamic>()),
    );
  }

  Future<AuditLogModel> byId(String id) async {
    final validId = InputValidators.requireUuid(id, field: 'registro');
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.auditLogById(validId),
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return AuditLogModel.fromJson(envelope.data!);
  }
}
