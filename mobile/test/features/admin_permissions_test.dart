import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/router/app_router.dart';
import 'package:mobile/core/session/auth_session.dart';

UserSummary _user(String role) => UserSummary(
      id: '00000000-0000-0000-0000-000000000001',
      email: 'usuario@prueba.com',
      fullName: 'Usuario de prueba',
      role: role,
    );

void main() {
  group('permisos por rol (espejo de @PreAuthorize)', () {
    test('PLATFORM_ADMIN puede administrar y crear instituciones', () {
      final user = _user('PLATFORM_ADMIN');
      expect(user.isPlatformAdmin, isTrue);
      expect(user.canAdministrate, isTrue);
      expect(user.canViewUsers, isTrue);
      expect(user.canManageSettings, isTrue);
      expect(user.canViewAudit, isTrue);
      expect(user.canManageWebhooks, isTrue);
      expect(user.canCreateTenant, isTrue);
    });

    test('TENANT_ADMIN administra su banco pero no crea instituciones', () {
      final user = _user('TENANT_ADMIN');
      expect(user.isTenantAdmin, isTrue);
      expect(user.canAdministrate, isTrue);
      expect(user.canViewUsers, isTrue);
      expect(user.canManageCustomers, isTrue);
      expect(user.canManageSettings, isTrue);
      expect(user.canViewAudit, isTrue);
      expect(user.canCreateTenant, isFalse);
    });

    test('OPERATOR gestiona clientes pero no usuarios ni auditoría', () {
      final user = _user('OPERATOR');
      expect(user.isOperator, isTrue);
      expect(user.canViewUsers, isFalse);
      expect(user.canViewCustomers, isTrue);
      expect(user.canManageCustomers, isTrue);
      expect(user.canViewSettings, isTrue);
      expect(user.canManageSettings, isFalse);
      expect(user.canViewAudit, isFalse);
      expect(user.canViewWebhooks, isFalse);
      expect(user.canCreateTenant, isFalse);
    });

    test('AUDITOR solo consulta clientes, settings, auditoría y webhooks', () {
      final user = _user('AUDITOR');
      expect(user.isAuditor, isTrue);
      expect(user.canViewUsers, isFalse);
      expect(user.canViewCustomers, isTrue);
      expect(user.canManageCustomers, isFalse);
      expect(user.canViewSettings, isTrue);
      expect(user.canManageSettings, isFalse);
      expect(user.canViewAudit, isTrue);
      expect(user.canViewWebhooks, isTrue);
      expect(user.canManageWebhooks, isFalse);
      expect(user.canCreateTenant, isFalse);
    });
  });

  group('canAccessAdminPath', () {
    test('OPERATOR entra a clientes/settings pero no a usuarios ni tenants', () {
      final user = _user('OPERATOR');
      expect(canAccessAdminPath(user, '/admin'), isTrue);
      expect(canAccessAdminPath(user, '/admin/customers'), isTrue);
      expect(canAccessAdminPath(user, '/admin/settings'), isTrue);
      expect(canAccessAdminPath(user, '/admin/users'), isFalse);
      expect(canAccessAdminPath(user, '/admin/audit'), isFalse);
      expect(canAccessAdminPath(user, '/admin/webhooks'), isFalse);
      expect(canAccessAdminPath(user, '/admin/tenants'), isFalse);
    });

    test('AUDITOR entra a audit/webhooks pero no a usuarios ni tenants', () {
      final user = _user('AUDITOR');
      expect(canAccessAdminPath(user, '/admin/audit'), isTrue);
      expect(canAccessAdminPath(user, '/admin/webhooks'), isTrue);
      expect(canAccessAdminPath(user, '/admin/users'), isFalse);
      expect(canAccessAdminPath(user, '/admin/tenants'), isFalse);
    });

    test('PLATFORM_ADMIN entra a todos los módulos', () {
      final user = _user('PLATFORM_ADMIN');
      for (final path in <String>[
        '/admin',
        '/admin/users',
        '/admin/customers',
        '/admin/settings',
        '/admin/audit',
        '/admin/webhooks',
        '/admin/tenants',
      ]) {
        expect(canAccessAdminPath(user, path), isTrue, reason: path);
      }
    });
  });
}
