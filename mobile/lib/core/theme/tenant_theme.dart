import 'package:material_ui/material_ui.dart';

import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/shared/constants/app_colors.dart';

/// Colores del banco activo, derivados del `TenantSummary` del login.
class TenantTheme {
  const TenantTheme({
    required this.primary,
    required this.secondary,
    this.logoUrl,
    this.tenantName,
  });

  final Color primary;
  final Color secondary;
  final String? logoUrl;
  final String? tenantName;

  factory TenantTheme.fromSession(AuthSession? session) {
    if (session == null) return fallback();
    return TenantTheme(
      primary: parseHex(session.tenant.primaryColor) ?? AppColors.primary,
      secondary: parseHex(session.tenant.secondaryColor) ?? AppColors.primaryDark,
      logoUrl: session.tenant.logoUrl,
      tenantName: session.tenant.name,
    );
  }

  factory TenantTheme.fromLinkedBank(LinkedBankModel? bank) {
    if (bank == null) return fallback();
    return TenantTheme(
      primary: parseHex(bank.primaryColor) ?? AppColors.primary,
      secondary: parseHex(bank.secondaryColor) ?? AppColors.primaryDark,
      logoUrl: bank.logoUrl,
      tenantName: bank.tenantName,
    );
  }

  static TenantTheme fallback() => const TenantTheme(
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
      );

  static Color? parseHex(String value) {
    final raw = value.trim().replaceFirst('#', '');
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(raw)) return null;
    if (raw.length == 6) {
      return Color(int.parse('FF$raw', radix: 16));
    }
    if (raw.length == 8) {
      return Color(int.parse(raw, radix: 16));
    }
    return null;
  }
}
