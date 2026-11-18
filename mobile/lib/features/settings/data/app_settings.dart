import 'package:decimal/decimal.dart';

/// `GET/PUT /settings`: mapa de claves del tenant. Los valores viajan como
/// `String` y se interpretan con `Decimal` cuando son monetarios.
class TenantSettings {
  const TenantSettings({required this.values});

  final Map<String, String> values;

  factory TenantSettings.fromJson(Map<String, dynamic> json) {
    final raw = (json['settings'] as Map?) ?? const <String, dynamic>{};
    return TenantSettings(
      values: raw.map(
        (key, value) => MapEntry<String, String>(key.toString(), '$value'),
      ),
    );
  }

  String operator [](String key) => values[key] ?? '';

  String get feeFixed => this['transfer.fee.fixed'];
  String get feePercent => this['transfer.fee.percent'];

  Decimal feeFixedDecimal() => Decimal.tryParse(feeFixed) ?? Decimal.zero;
  Decimal feePercentDecimal() => Decimal.tryParse(feePercent) ?? Decimal.zero;
}

class ExchangeRateModel {
  const ExchangeRateModel({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String fromCurrency;
  final String toCurrency;
  final String rate;
  final String effectiveFrom;
  final String? effectiveTo;
  final bool active;
  final String createdAt;

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      id: (json['id'] as String?) ?? '',
      fromCurrency: (json['from_currency'] as String?) ?? '',
      toCurrency: (json['to_currency'] as String?) ?? '',
      rate: (json['rate'] as String?) ?? '0.00000000',
      effectiveFrom: (json['effective_from'] as String?) ?? '',
      effectiveTo: json['effective_to'] as String?,
      active: json['active'] as bool? ?? false,
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }

  String get pair => '$fromCurrency → $toCurrency';
}
