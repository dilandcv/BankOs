import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_response.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/customers/data/customer.dart';
import 'package:mobile/features/customers/data/customers_repository.dart';

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  return CustomersRepository(ref.watch(apiClientProvider));
});

final customersProvider = FutureProvider<PageResponse<CustomerModel>>((ref) async {
  ref.watch(sessionControllerProvider);
  ref.watch(dataVersionProvider);
  return ref.read(customersRepositoryProvider).list();
});
