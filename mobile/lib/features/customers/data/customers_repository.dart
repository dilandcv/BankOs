import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/utils/input_validators.dart';
import 'package:mobile/features/customers/data/customer.dart';

class CustomersRepository {
  CustomersRepository(this._api);

  final ApiClient _api;

  Future<PageResponse<CustomerModel>> list({int page = 0, int size = 20}) async {
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.customers,
      queryParameters: <String, dynamic>{'page': page, 'size': size},
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return PageResponse<CustomerModel>.fromJson(
      envelope.data!,
      (item) => CustomerModel.fromJson((item as Map).cast<String, dynamic>()),
    );
  }

  Future<CustomerModel> byId(String id) async {
    final validId = InputValidators.requireUuid(id, field: 'cliente');
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.customerById(validId),
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return CustomerModel.fromJson(envelope.data!);
  }

  Future<CustomerModel> create({
    required String documentType,
    required String documentNumber,
    required String fullName,
  }) async {
    final envelope = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.customers,
      data: <String, dynamic>{
        'document_type':
            InputValidators.requireText(documentType, field: 'tipo de documento')
                .toUpperCase(),
        'document_number':
            InputValidators.requireText(documentNumber, field: 'número de documento'),
        'full_name': InputValidators.requireText(fullName, field: 'nombre'),
      },
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return CustomerModel.fromJson(envelope.data!);
  }
}
