import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/utils/input_validators.dart';
import 'package:mobile/features/webhooks/data/webhook.dart';

class WebhooksRepository {
  WebhooksRepository(this._api);

  final ApiClient _api;

  Future<List<WebhookModel>> list() async {
    final envelope = await _api.get<List<dynamic>>(
      ApiEndpoints.webhooks,
      parse: (data) => (data as List<dynamic>),
    );
    return (envelope.data ?? const <dynamic>[])
        .map((item) => WebhookModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList(growable: false);
  }

  /// El secreto nunca se devuelve en la respuesta del backend.
  Future<WebhookModel> create({
    required String url,
    required String events,
    required String secret,
  }) async {
    final envelope = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.webhooks,
      data: <String, dynamic>{
        'url': InputValidators.requireText(url, field: 'URL'),
        'events': InputValidators.requireText(events, field: 'eventos'),
        'secret': InputValidators.requireText(secret, field: 'secreto'),
      },
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return WebhookModel.fromJson(envelope.data!);
  }

  Future<PageResponse<OutboxEventModel>> events({int page = 0, int size = 20}) async {
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.webhookEvents,
      queryParameters: <String, dynamic>{'page': page, 'size': size},
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return PageResponse<OutboxEventModel>.fromJson(
      envelope.data!,
      (item) => OutboxEventModel.fromJson((item as Map).cast<String, dynamic>()),
    );
  }
}
