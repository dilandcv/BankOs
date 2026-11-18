import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/utils/input_validators.dart';
import 'package:mobile/features/accounts/data/account.dart';

class AccountsRepository {
  AccountsRepository(this._api);

  final ApiClient _api;

  Future<List<AccountModel>> listAll() async {
    final envelope = await _api.get<List<dynamic>>(
      ApiEndpoints.accountsAll,
      parse: (data) => (data as List<dynamic>),
    );
    return (envelope.data ?? const <dynamic>[])
        .map((item) => AccountModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<PageResponse<AccountModel>> listPaged({
    int page = 0,
    int size = 20,
  }) async {
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.accounts,
      queryParameters: <String, dynamic>{'page': page, 'size': size},
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );

    return PageResponse<AccountModel>.fromJson(
      envelope.data!,
      (item) => AccountModel.fromJson((item as Map).cast<String, dynamic>()),
    );
  }

  Future<AccountModel> byId(String id) async {
    final validId = InputValidators.requireUuid(id, field: 'cuenta');
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.accountById(validId),
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return AccountModel.fromJson(envelope.data!);
  }
}
