import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/settings/data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(apiClientProvider));
});

final tenantSettingsProvider = FutureProvider((ref) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(settingsRepositoryProvider).settings();
});

final exchangeRatesProvider = FutureProvider((ref) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(settingsRepositoryProvider).rates();
});
