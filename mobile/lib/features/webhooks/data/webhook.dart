class WebhookModel {
  const WebhookModel({
    required this.id,
    required this.url,
    required this.events,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String url;
  final String events;
  final String status;
  final String createdAt;

  factory WebhookModel.fromJson(Map<String, dynamic> json) {
    return WebhookModel(
      id: (json['id'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      events: (json['events'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }
}

class OutboxEventModel {
  const OutboxEventModel({
    required this.id,
    required this.webhookConfigId,
    required this.eventType,
    required this.payload,
    required this.status,
    required this.attempts,
    required this.nextRetryAt,
    required this.processedAt,
    required this.createdAt,
  });

  final String id;
  final String webhookConfigId;
  final String eventType;
  final String payload;
  final String status;
  final int attempts;
  final String? nextRetryAt;
  final String? processedAt;
  final String createdAt;

  factory OutboxEventModel.fromJson(Map<String, dynamic> json) {
    return OutboxEventModel(
      id: (json['id'] as String?) ?? '',
      webhookConfigId: (json['webhook_config_id'] as String?) ?? '',
      eventType: (json['event_type'] as String?) ?? '',
      payload: (json['payload'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      nextRetryAt: json['next_retry_at'] as String?,
      processedAt: json['processed_at'] as String?,
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }
}
