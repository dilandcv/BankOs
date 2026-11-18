import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/webhooks/data/webhook.dart';
import 'package:mobile/features/webhooks/data/webhooks_repository.dart';

final webhooksRepositoryProvider = Provider<WebhooksRepository>((ref) {
  return WebhooksRepository(ref.watch(apiClientProvider));
});

final webhooksProvider = FutureProvider<List<WebhookModel>>((ref) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(webhooksRepositoryProvider).list();
});

final outboxEventsProvider =
    FutureProvider<PageResponse<OutboxEventModel>>((ref) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(webhooksRepositoryProvider).events();
});
