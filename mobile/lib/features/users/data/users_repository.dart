import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/utils/input_validators.dart';
import 'package:mobile/features/users/data/user.dart';

class UsersRepository {
  UsersRepository(this._api);

  final ApiClient _api;

  Future<PageResponse<UserModel>> list({int page = 0, int size = 20}) async {
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.users,
      queryParameters: <String, dynamic>{'page': page, 'size': size},
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return PageResponse<UserModel>.fromJson(
      envelope.data!,
      (item) => UserModel.fromJson((item as Map).cast<String, dynamic>()),
    );
  }

  Future<UserModel> byId(String id) async {
    final validId = InputValidators.requireUuid(id, field: 'usuario');
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.userById(validId),
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return UserModel.fromJson(envelope.data!);
  }

  Future<UserModel> create({
    required String email,
    required String fullName,
    required String password,
    required String role,
  }) async {
    final envelope = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.users,
      data: <String, dynamic>{
        'email': InputValidators.requireText(email, field: 'correo').toLowerCase(),
        'full_name': InputValidators.requireText(fullName, field: 'nombre'),
        'password': InputValidators.requireText(password, field: 'contraseña'),
        'role': InputValidators.requireText(role, field: 'rol').toUpperCase(),
      },
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return UserModel.fromJson(envelope.data!);
  }
}
