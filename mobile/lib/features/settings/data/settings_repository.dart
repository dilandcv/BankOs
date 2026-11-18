import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/utils/input_validators.dart';
import 'package:mobile/features/settings/data/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._api);

  final ApiClient _api;

  Future<TenantSettings> settings() async {
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.settings,
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return TenantSettings.fromJson(envelope.data!);
  }

  Future<TenantSettings> updateSettings(Map<String, String> settings) async {
    final envelope = await _api.request<Map<String, dynamic>>(
      ApiEndpoints.settings,
      method: 'PUT',
      data: <String, dynamic>{
        'settings': Map<String, String>.from(settings),
      },
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return TenantSettings.fromJson(envelope.data!);
  }

  Future<List<ExchangeRateModel>> rates() async {
    final envelope = await _api.get<List<dynamic>>(
      ApiEndpoints.exchangeRates,
      parse: (data) => (data as List<dynamic>),
    );
    return (envelope.data ?? const <dynamic>[])
        .map((item) =>
            ExchangeRateModel.fromJson((item as Map).cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<ExchangeRateModel> rateById(String id) async {
    final validId = InputValidators.requireUuid(id, field: 'tasa');
    final envelope = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.exchangeRateById(validId),
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return ExchangeRateModel.fromJson(envelope.data!);
  }

  Future<ExchangeRateModel> createRate({
    required String fromCurrency,
    required String toCurrency,
    required String rate,
    required String effectiveFrom,
    String? effectiveTo,
  }) async {
    final envelope = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.exchangeRates,
      data: <String, dynamic>{
        'from_currency':
            InputValidators.requireText(fromCurrency, field: 'moneda origen')
                .toUpperCase(),
        'to_currency':
            InputValidators.requireText(toCurrency, field: 'moneda destino')
                .toUpperCase(),
        'rate': InputValidators.requireText(rate, field: 'tasa'),
        'effective_from':
            InputValidators.requireText(effectiveFrom, field: 'vigencia desde'),
        'effective_to': (effectiveTo == null || effectiveTo.trim().isEmpty)
            ? null
            : effectiveTo.trim(),
      },
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return ExchangeRateModel.fromJson(envelope.data!);
  }
}
