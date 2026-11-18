class AuditLogModel {
  const AuditLogModel({
    required this.id,
    required this.actorUserId,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.metadata,
    required this.correlationId,
    required this.createdAt,
  });

  final String id;
  final String actorUserId;
  final String action;
  final String resourceType;
  final String resourceId;
  final String metadata;
  final String correlationId;
  final String createdAt;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: (json['id'] as String?) ?? '',
      actorUserId: (json['actor_user_id'] as String?) ?? '',
      action: (json['action'] as String?) ?? '',
      resourceType: (json['resource_type'] as String?) ?? '',
      resourceId: (json['resource_id'] as String?) ?? '',
      metadata: (json['metadata'] as String?) ?? '',
      correlationId: (json['correlation_id'] as String?) ?? '',
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }

  String get shortDate {
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) return createdAt;
    final local = parsed.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
