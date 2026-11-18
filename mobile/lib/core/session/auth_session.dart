import 'dart:convert';

/// Usuario resumido devuelto por `/auth/login` y `/auth/me`.
class UserSummary {
  const UserSummary({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: (json['id'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'full_name': fullName,
        'role': role,
      };

  bool get isPlatformAdmin => role == 'PLATFORM_ADMIN';
  bool get isTenantAdmin => role == 'TENANT_ADMIN';
  bool get isOperator => role == 'OPERATOR';
  bool get isAuditor => role == 'AUDITOR';
  bool get canAdministrate => isPlatformAdmin || isTenantAdmin;

  /// Permisos espejo de los `@PreAuthorize` del backend.
  bool get canViewUsers => canAdministrate;
  bool get canViewCustomers =>
      isPlatformAdmin || isTenantAdmin || isOperator || isAuditor;
  bool get canManageCustomers => isTenantAdmin || isOperator;
  bool get canViewSettings => canViewCustomers;
  bool get canManageSettings => canAdministrate;
  bool get canViewAudit => isPlatformAdmin || isTenantAdmin || isAuditor;
  bool get canViewWebhooks => canViewAudit;
  bool get canManageWebhooks => canAdministrate;
  bool get canCreateTenant => isPlatformAdmin;

  @override
  String toString() => 'UserSummary($email, $role)';
}

/// Tenant resumido con la marca que el cliente debe aplicar (F3).
class TenantSummary {
  const TenantSummary({
    required this.id,
    required this.code,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    this.logoUrl,
  });

  final String id;
  final String code;
  final String name;
  final String primaryColor;
  final String secondaryColor;
  final String? logoUrl;

  factory TenantSummary.fromJson(Map<String, dynamic> json) {
    return TenantSummary(
      id: (json['id'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      primaryColor: (json['primary_color'] as String?) ?? '',
      secondaryColor: (json['secondary_color'] as String?) ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'code': code,
        'name': name,
        'primary_color': primaryColor,
        'secondary_color': secondaryColor,
        'logo_url': logoUrl,
      };

  @override
  String toString() => 'TenantSummary($code)';
}

/// Sesión de un banco. Se persiste por `tenant.code` en almacenamiento seguro.
class AuthSession {
  AuthSession({
    required this.accessToken,
    required this.user,
    required this.tenant,
    this.tokenType = 'Bearer',
    this.expiresIn = 3600,
    DateTime? issuedAt,
  }) : issuedAt = issuedAt ?? DateTime.now();

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final DateTime issuedAt;
  final UserSummary user;
  final TenantSummary tenant;

  DateTime get expiresAt => issuedAt.add(Duration(seconds: expiresIn));

  /// Considera vencido el token algo antes para evitar usarlo en la frontera.
  bool isExpired({
    DateTime? now,
    Duration skew = const Duration(seconds: 30),
  }) {
    final reference = now ?? DateTime.now();
    return !reference.isBefore(expiresAt.subtract(skew));
  }

  /// Construye la sesión desde el `data` de `POST /auth/login`.
  factory AuthSession.fromLogin(
    Map<String, dynamic> data, {
    DateTime? issuedAt,
  }) {
    final userJson = (data['user'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final tenantJson = (data['tenant'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    return AuthSession(
      accessToken: (data['access_token'] as String?) ?? '',
      tokenType: (data['token_type'] as String?) ?? 'Bearer',
      expiresIn: (data['expires_in'] as num?)?.toInt() ?? 3600,
      user: UserSummary.fromJson(userJson),
      tenant: TenantSummary.fromJson(tenantJson),
      issuedAt: issuedAt,
    );
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final issuedAtRaw = json['issued_at'] as String?;
    final userJson =
        (json['user'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final tenantJson =
        (json['tenant'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    return AuthSession(
      accessToken: (json['access_token'] as String?) ?? '',
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 3600,
      issuedAt: issuedAtRaw != null
          ? DateTime.tryParse(issuedAtRaw) ?? DateTime.now()
          : DateTime.now(),
      user: UserSummary.fromJson(userJson),
      tenant: TenantSummary.fromJson(tenantJson),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'issued_at': issuedAt.toIso8601String(),
        'user': user.toJson(),
        'tenant': tenant.toJson(),
      };

  String serialize() => jsonEncode(toJson());

  factory AuthSession.deserialize(String raw) {
    return AuthSession.fromJson(
      (jsonDecode(raw) as Map).cast<String, dynamic>(),
    );
  }

  AuthSession copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    DateTime? issuedAt,
    UserSummary? user,
    TenantSummary? tenant,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      issuedAt: issuedAt ?? this.issuedAt,
      user: user ?? this.user,
      tenant: tenant ?? this.tenant,
    );
  }
}
