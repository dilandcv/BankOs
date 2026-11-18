import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/utils/input_validators.dart';
import 'package:mobile/features/tenants/data/tenant.dart';

class TenantsRepository {
  TenantsRepository(this._api);

  final ApiClient _api;

  /// Requiere `PLATFORM_ADMIN` o `TENANT_ADMIN`. Para otros roles el caller
  /// debe caer a las sesiones guardadas localmente.
  Future<List<TenantModel>> list() async {
    final envelope = await _api.get<List<dynamic>>(
      ApiEndpoints.tenants,
      parse: (data) => (data as List<dynamic>),
    );
    return (envelope.data ?? const <dynamic>[])
        .map((item) => TenantModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList(growable: false);
  }

  /// Alta de institución: solo `PLATFORM_ADMIN` en el backend.
  Future<TenantModel> create({
    required String code,
    required String name,
    required String primaryColor,
    required String secondaryColor,
    String? logoUrl,
  }) async {
    final envelope = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.tenants,
      data: <String, dynamic>{
        'code': InputValidators.requireText(code, field: 'código').toUpperCase(),
        'name': InputValidators.requireText(name, field: 'nombre'),
        'primary_color': InputValidators.requireText(primaryColor, field: 'color primario'),
        'secondary_color': InputValidators.requireText(secondaryColor, field: 'color secundario'),
        'logo_url': (logoUrl == null || logoUrl.trim().isEmpty) ? null : logoUrl.trim(),
      },
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return TenantModel.fromJson(envelope.data!);
  }
}
