import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/session/auth_session.dart';
import 'package:mobile/core/storage/secure_session_store.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';

import '../helpers/fake_adapter.dart';

void main() {
  group('Master Auth & Instagram-Style Switcher', () {
    late MemorySessionStorage storage;
    late RoutingFakeAdapter adapter;
    late ProviderContainer container;

    setUp(() {
      storage = MemorySessionStorage();
      adapter = RoutingFakeAdapter();

      final dio = Dio()..httpClientAdapter = adapter;
      final store = SecureSessionStore(storage: storage);
      final client = ApiClient(baseUrl: 'http://localhost:8080/api/v1', sessionStore: store, dio: dio);
      final repo = AuthRepository(client, store);

      container = ProviderContainer(
        overrides: [
          secureSessionStoreProvider.overrideWithValue(store),
          dioProvider.overrideWithValue(dio),
          apiClientProvider.overrideWithValue(client),
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('MasterSession se serializa y deserializa conservando entidades vinculadas', () {
      final now = DateTime.now();
      final session = MasterSession(
        accessToken: 'master-token-abc',
        user: const MasterUserSummary(
          id: 'u-1',
          email: 'usuario@bankos.com',
          fullName: 'María González',
          phone: '+57 300 1234567',
        ),
        linkedBanks: [
          const LinkedBankModel(
            linkId: 'lnk-1',
            tenantId: 't-nequi',
            tenantCode: 'NEQUI',
            tenantName: 'Nequi',
            primaryColor: '#6E2585',
            secondaryColor: '#A64AC9',
            accountNickname: 'Nequi Personal',
            accountNumberMask: '•••• 4567',
            authStatus: 'CONNECTED',
            isDefault: true,
          ),
          const LinkedBankModel(
            linkId: 'lnk-2',
            tenantId: 't-daviplata',
            tenantCode: 'DAVIPLATA',
            tenantName: 'Daviplata',
            primaryColor: '#E30613',
            secondaryColor: '#FF5A5F',
            accountNickname: 'Daviplata Ahorros',
            accountNumberMask: '•••• 9876',
            authStatus: 'CONNECTED',
            isDefault: false,
          ),
        ],
        issuedAt: now,
      );

      final serialized = session.serialize();
      final restored = MasterSession.deserialize(serialized);

      expect(restored.accessToken, 'master-token-abc');
      expect(restored.user.fullName, 'María González');
      expect(restored.linkedBanks.length, 2);
      expect(restored.linkedBanks[0].tenantCode, 'NEQUI');
      expect(restored.linkedBanks[0].isDefault, isTrue);
      expect(restored.linkedBanks[1].tenantCode, 'DAVIPLATA');
      expect(restored.linkedBanks[1].isDefault, isFalse);
    });

    test('loginMaster ejecuta inicio de sesión único y puebla masterSessionProvider', () async {
      adapter.routes[ApiEndpoints.authLogin] = FakeResponse(200, {
        'success': true,
        'code': 'LOGIN_SUCCESS',
        'data': {
          'access_token': 'master-jwt-token',
          'token_type': 'Bearer',
          'expires_in': 7200,
          'master_user': {
            'id': 'u-100',
            'email': 'usuario@bankos.com',
            'full_name': 'María González',
            'phone': '+57 300 1234567',
          },
          'linked_banks': [
            {
              'link_id': 'lnk-nequi',
              'tenant_id': '00000000-0000-0000-0000-000000000002',
              'tenant_code': 'NEQUI',
              'tenant_name': 'Nequi',
              'primary_color': '#6E2585',
              'secondary_color': '#A64AC9',
              'account_nickname': 'Nequi Personal',
              'account_number_mask': '•••• 4567',
              'auth_status': 'CONNECTED',
              'is_default': true,
            },
          ],
        },
      });

      final repo = container.read(authRepositoryProvider);
      final masterSession = await repo.loginMaster(
        email: 'usuario@bankos.com',
        password: 'Admin123!',
      );

      expect(masterSession.accessToken, 'master-jwt-token');
      expect(masterSession.user.fullName, 'María González');
      expect(masterSession.linkedBanks.length, 1);
      expect(masterSession.linkedBanks.first.tenantCode, 'NEQUI');

      await container.read(masterSessionControllerProvider.notifier).setSession(masterSession);

      expect(container.read(isMasterAuthenticatedProvider), isTrue);
      expect(container.read(linkedBanksProvider).length, 1);
      expect(container.read(linkedBanksProvider).first.tenantName, 'Nequi');
    });

    test('exchangeBankToken canjea token y activa la sesión del banco correspondiente', () async {
      adapter.routes[ApiEndpoints.authExchangeBankToken] = FakeResponse(200, {
        'success': true,
        'code': 'TOKEN_EXCHANGED',
        'data': {
          'access_token': 'tenant-token-nequi',
          'token_type': 'Bearer',
          'expires_in': 3600,
          'user': {
            'id': 'u-100',
            'email': 'usuario@bankos.com',
            'full_name': 'María González',
            'role': 'OPERATOR',
          },
          'tenant': {
            'id': '00000000-0000-0000-0000-000000000002',
            'code': 'NEQUI',
            'name': 'Nequi',
            'primary_color': '#6E2585',
            'secondary_color': '#A64AC9',
          },
        },
      });

      final bankSession = await container.read(sessionControllerProvider.notifier).switchBank('NEQUI');

      expect(bankSession.accessToken, 'tenant-token-nequi');
      expect(bankSession.tenant.code, 'NEQUI');
      expect(container.read(sessionControllerProvider).value?.tenant.code, 'NEQUI');
      expect(container.read(tenantThemeProvider).primary, const Color(0xFF6E2585));
    });

    test('linkBank asocia una nueva entidad bancaria y actualiza catálogo', () async {
      adapter.routes[ApiEndpoints.banksLink] = FakeResponse(200, {
        'success': true,
        'code': 'BANK_LINKED',
        'data': {
          'link_id': 'lnk-daviplata',
          'tenant_id': '00000000-0000-0000-0000-000000000003',
          'tenant_code': 'DAVIPLATA',
          'tenant_name': 'Daviplata',
          'primary_color': '#E30613',
          'secondary_color': '#FF5A5F',
          'account_nickname': 'Daviplata Ahorros',
          'account_number_mask': '•••• 9876',
          'auth_status': 'CONNECTED',
          'is_default': false,
        },
      });

      final repo = container.read(authRepositoryProvider);
      final newLink = await repo.linkBank(
        tenantCode: 'DAVIPLATA',
        accountNickname: 'Daviplata Ahorros',
        accountType: 'SAVINGS',
      );

      expect(newLink.tenantCode, 'DAVIPLATA');
      expect(newLink.tenantName, 'Daviplata');
      expect(newLink.accountNickname, 'Daviplata Ahorros');
      expect(newLink.isConnected, isTrue);
    });
  });
}
