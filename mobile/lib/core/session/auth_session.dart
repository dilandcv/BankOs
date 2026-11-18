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

/// Identidad maestra del usuario central en BankOS.
class MasterUserSummary {
  const MasterUserSummary({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;

  factory MasterUserSummary.fromJson(Map<String, dynamic> json) {
    return MasterUserSummary(
      id: (json['id'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
      };
}

/// Entidad bancaria vinculada al usuario maestro.
class LinkedBankModel {
  const LinkedBankModel({
    required this.linkId,
    required this.tenantId,
    required this.tenantCode,
    required this.tenantName,
    required this.primaryColor,
    required this.secondaryColor,
    this.logoUrl,
    required this.accountNickname,
    required this.accountNumberMask,
    this.accountType = 'SAVINGS',
    this.authStatus = 'CONNECTED',
    this.authMechanism = 'OAUTH2',
    this.isDefault = false,
    this.lastSyncAt,
  });

  final String linkId;
  final String tenantId;
  final String tenantCode;
  final String tenantName;
  final String primaryColor;
  final String secondaryColor;
  final String? logoUrl;
  final String accountNickname;
  final String accountNumberMask;
  final String accountType;
  final String authStatus;
  final String authMechanism;
  final bool isDefault;
  final DateTime? lastSyncAt;

  bool get isConnected => authStatus == 'CONNECTED';
  bool get requiresReauth => authStatus == 'PENDING_REAUTH';

  factory LinkedBankModel.fromJson(Map<String, dynamic> json) {
    final syncRaw = json['last_sync_at'] as String?;
    return LinkedBankModel(
      linkId: (json['link_id'] as String?) ?? '',
      tenantId: (json['tenant_id'] as String?) ?? '',
      tenantCode: (json['tenant_code'] as String?) ?? '',
      tenantName: (json['tenant_name'] as String?) ?? '',
      primaryColor: (json['primary_color'] as String?) ?? '#0B1F3A',
      secondaryColor: (json['secondary_color'] as String?) ?? '#0070BA',
      logoUrl: json['logo_url'] as String?,
      accountNickname: (json['account_nickname'] as String?) ?? '',
      accountNumberMask: (json['account_number_mask'] as String?) ?? '',
      accountType: (json['account_type'] as String?) ?? 'SAVINGS',
      authStatus: (json['auth_status'] as String?) ?? 'CONNECTED',
      authMechanism: (json['auth_mechanism'] as String?) ?? 'OAUTH2',
      isDefault: (json['is_default'] as bool?) ?? false,
      lastSyncAt: syncRaw != null ? DateTime.tryParse(syncRaw) : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'link_id': linkId,
        'tenant_id': tenantId,
        'tenant_code': tenantCode,
        'tenant_name': tenantName,
        'primary_color': primaryColor,
        'secondary_color': secondaryColor,
        'logo_url': logoUrl,
        'account_nickname': accountNickname,
        'account_number_mask': accountNumberMask,
        'account_type': accountType,
        'auth_status': authStatus,
        'auth_mechanism': authMechanism,
        'is_default': isDefault,
        'last_sync_at': lastSyncAt?.toIso8601String(),
      };
}

/// Tenant resumido con la marca que el cliente debe aplicar.
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

/// Sesión maestra de la plataforma BankOS.
class MasterSession {
  MasterSession({
    required this.accessToken,
    required this.user,
    required this.linkedBanks,
    this.tokenType = 'Bearer',
    this.expiresIn = 7200,
    DateTime? issuedAt,
  }) : issuedAt = issuedAt ?? DateTime.now();

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final DateTime issuedAt;
  final MasterUserSummary user;
  final List<LinkedBankModel> linkedBanks;

  DateTime get expiresAt => issuedAt.add(Duration(seconds: expiresIn));

  bool isExpired({
    DateTime? now,
    Duration skew = const Duration(seconds: 30),
  }) {
    final reference = now ?? DateTime.now();
    return !reference.isBefore(expiresAt.subtract(skew));
  }

  factory MasterSession.fromJson(Map<String, dynamic> json) {
    final issuedAtRaw = json['issued_at'] as String?;
    final userJson =
        (json['user'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final banksList = (json['linked_banks'] as List?) ?? const [];

    return MasterSession(
      accessToken: (json['access_token'] as String?) ?? '',
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 7200,
      issuedAt: issuedAtRaw != null
          ? DateTime.tryParse(issuedAtRaw) ?? DateTime.now()
          : DateTime.now(),
      user: MasterUserSummary.fromJson(userJson),
      linkedBanks: banksList
          .map((item) => LinkedBankModel.fromJson((item as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'issued_at': issuedAt.toIso8601String(),
        'user': user.toJson(),
        'linked_banks': linkedBanks.map((b) => b.toJson()).toList(),
      };

  String serialize() => jsonEncode(toJson());

  factory MasterSession.deserialize(String raw) {
    return MasterSession.fromJson(
      (jsonDecode(raw) as Map).cast<String, dynamic>(),
    );
  }

  MasterSession copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    DateTime? issuedAt,
    MasterUserSummary? user,
    List<LinkedBankModel>? linkedBanks,
  }) {
    return MasterSession(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      issuedAt: issuedAt ?? this.issuedAt,
      user: user ?? this.user,
      linkedBanks: linkedBanks ?? this.linkedBanks,
    );
  }
}

/// Sesión de un banco activo.
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

  bool isExpired({
    DateTime? now,
    Duration skew = const Duration(seconds: 30),
  }) {
    final reference = now ?? DateTime.now();
    return !reference.isBefore(expiresAt.subtract(skew));
  }

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
