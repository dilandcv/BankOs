class TenantModel {
  const TenantModel({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    required this.primaryColor,
    required this.secondaryColor,
    this.logoUrl,
  });

  final String id;
  final String code;
  final String name;
  final String status;
  final String primaryColor;
  final String secondaryColor;
  final String? logoUrl;

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: (json['id'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      primaryColor: (json['primary_color'] as String?) ?? '',
      secondaryColor: (json['secondary_color'] as String?) ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
