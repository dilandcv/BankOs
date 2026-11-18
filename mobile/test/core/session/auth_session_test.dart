import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/session/auth_session.dart';

Map<String, dynamic> _loginData() {
  final json = jsonDecode(File('test/fixtures/login_response.json').readAsStringSync())
      as Map<String, dynamic>;
  return (json['data'] as Map).cast<String, dynamic>();
}

void main() {
  group('AuthSession', () {
    test('se construye desde el login real y expira con skew de 30s', () {
      final issuedAt = DateTime.parse('2026-11-17T12:00:00Z');
      final session = AuthSession.fromLogin(_loginData(), issuedAt: issuedAt);

      expect(session.accessToken, '<REDACTED>');
      expect(session.tokenType, 'Bearer');
      expect(session.expiresIn, 3600);
      expect(session.user.email, 'admin@horizonte.com');
      expect(session.user.role, 'TENANT_ADMIN');
      expect(session.user.canAdministrate, isTrue);
      expect(session.tenant.code, 'BANCO_HORIZONTE');
      expect(session.tenant.primaryColor, '#0070BA');
      expect(session.tenant.logoUrl, isNull);
      expect(session.expiresAt, issuedAt.add(const Duration(hours: 1)));

      expect(session.isExpired(now: issuedAt), isFalse);
      expect(
        session.isExpired(now: issuedAt.add(const Duration(seconds: 3560))),
        isFalse,
      );
      expect(
        session.isExpired(now: issuedAt.add(const Duration(seconds: 3580))),
        isTrue,
      );
    });

    test('sobrevive a serialize/deserialize', () {
      final session = AuthSession.fromLogin(
        _loginData(),
        issuedAt: DateTime.parse('2026-11-17T12:00:00Z'),
      );

      final restored = AuthSession.deserialize(session.serialize());

      expect(restored.accessToken, session.accessToken);
      expect(restored.issuedAt, session.issuedAt);
      expect(restored.user.fullName, session.user.fullName);
      expect(restored.tenant.code, session.tenant.code);
      expect(restored.tenant.secondaryColor, '#003087');
      expect(restored.isExpired(now: session.issuedAt), isFalse);
    });
  });
}
