import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/core/storage/secure_session_store.dart';
import 'package:mobile/features/accounts/data/accounts_providers.dart';
import 'package:mobile/features/transactions/data/transactions_providers.dart';
import 'package:mobile/features/transactions/data/transaction.dart';

import '../helpers/fake_adapter.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _operation() => <String, dynamic>{
      'success': true,
      'code': 'TRANSACTION_COMPLETED',
      'message': 'Operación realizada correctamente',
      'data': <String, dynamic>{
        'id': '40000000-0000-0000-0000-000000000001',
        'type': 'DEPOSIT',
        'status': 'COMPLETED',
        'amount': '50.0000',
        'currency': 'USD',
        'fee': '0.0000',
        'exchange_rate': '1.00000000',
        'source_account_id': null,
        'destination_account_id': '30000000-0000-0000-0000-000000000001',
        'description': 'Depósito demo',
        'correlation_id': 'corr-op',
        'created_at': '2026-11-17T14:00:00Z',
        'entries': <dynamic>[],
      },
      'correlation_id': 'corr-op',
    };

void main() {
  late ProviderContainer container;
  late RoutingFakeAdapter adapter;
  late MemorySessionStorage storage;

  setUp(() {
    storage = MemorySessionStorage();
    adapter = RoutingFakeAdapter()
      ..routes[ApiEndpoints.authLogin] =
          FakeResponse(200, _fixture('login_response.json'))
      ..routes[ApiEndpoints.authMe] = FakeResponse(200, _fixture('me_response.json'))
      ..routes[ApiEndpoints.accountsAll] =
          FakeResponse(200, _fixture('accounts_all_response.json'))
      ..routes[ApiEndpoints.transactions] =
          FakeResponse(200, _fixture('transactions_empty_response.json'))
      ..routes[ApiEndpoints.deposits] = FakeResponse(200, _operation())
      ..routes[ApiEndpoints.transferPreview] =
          FakeResponse(200, _fixture('transfer_preview_response.json'));

    container = ProviderContainer(
      overrides: [
        secureSessionStoreProvider.overrideWithValue(
          SecureSessionStore(storage: storage),
        ),
        dioProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> signIn() async {
    final session = await container.read(authRepositoryProvider).login(
          tenantCode: 'BANCO_HORIZONTE',
          email: 'admin@horizonte.com',
          password: 'Admin123!',
        );
    await container.read(sessionControllerProvider.notifier).setSession(session);
  }

  test('login real guarda token y activa el banco', () async {
    final session = await container.read(authRepositoryProvider).login(
          tenantCode: 'banco_horizonte',
          email: 'admin@horizonte.com',
          password: 'Admin123!',
        );

    expect(session.tenant.code, 'BANCO_HORIZONTE');
    expect(storage.values.keys, contains('bankos.session.BANCO_HORIZONTE'));
    expect(await container.read(authRepositoryProvider).activeTenantCode(),
        'BANCO_HORIZONTE');

    final sent = adapter.requests.single.decodedBody!;
    expect(sent['tenant_code'], 'BANCO_HORIZONTE');
    expect(sent['password'], 'Admin123!');
  });

  test('/me devuelve la identidad del token', () async {
    await signIn();

    final identity = await container.read(authRepositoryProvider).me();
    expect(identity.user.role, 'TENANT_ADMIN');
    expect(identity.tenant.name, 'Banco Horizonte');
  });

  test('el dashboard obtiene cuentas reales y el historial vacío', () async {
    await signIn();

    final accounts = await container.read(accountsProvider.future);
    expect(accounts, hasLength(3));
    expect(accounts.first.balance, '8250.0000');
    expect(accounts.last.currency, 'EUR');

    final history = await container.read(transactionsProvider.future);
    expect(history.items, isEmpty);
    expect(history.totalElements, 0);
  });

  test('depósito envía Idempotency-Key y se reutiliza en el reintento', () async {
    await signIn();
    final repo = container.read(transactionsRepositoryProvider);

    for (var attempt = 0; attempt < 2; attempt++) {
      final result = await repo.deposit(
        accountId: '30000000-0000-0000-0000-000000000001',
        amount: '50.00',
        currency: 'USD',
        description: 'Depósito demo',
        idempotencyKey: 'key-estable',
      );
      expect(result.id, '40000000-0000-0000-0000-000000000001');
    }

    final deposits = adapter.requests
        .where((request) => request.options.path == ApiEndpoints.deposits)
        .toList();
    expect(deposits, hasLength(2));
    expect(
      deposits.map((request) => request.options.headers['Idempotency-Key']),
      everyElement('key-estable'),
    );
    expect(deposits.first.decodedBody!['account_id'],
        '30000000-0000-0000-0000-000000000001');
  });

  test('el filtro de historial usa accountId en camelCase', () async {
    await signIn();
    container.read(transactionFilterProvider.notifier).state =
        const TransactionFilter(
      accountId: '30000000-0000-0000-0000-000000000001',
      type: 'DEPOSIT',
    );

    await container.read(transactionsProvider.future);

    final historyRequest = adapter.requests.firstWhere(
      (request) => request.options.path == ApiEndpoints.transactions,
    );
    expect(historyRequest.options.queryParameters['accountId'],
        '30000000-0000-0000-0000-000000000001');
    expect(historyRequest.options.queryParameters['type'], 'DEPOSIT');
  });

  test('preview calcula comisión y conversión del backend', () async {
    await signIn();

    final preview = await container
        .read(transactionsRepositoryProvider)
        .preview(const TransferDraft(
          sourceAccountId: '30000000-0000-0000-0000-000000000001',
          targetAccountId: '30000000-0000-0000-0000-000000000003',
          amount: '100.00',
          currency: 'USD',
          description: '',
          idempotencyKey: 'key-preview',
        ));

    expect(preview.exchangeRate, '0.92000000');
    expect(preview.fee, '1.5000');
    expect(preview.debitAmount, '101.5000');
    expect(preview.creditAmount, '92.0000');
  });
}
