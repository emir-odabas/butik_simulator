import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/local_storage_providers.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/local/local_customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return LocalCustomerRepository(ref.watch(localStorageServiceProvider));
});

/// The simulated customer list. Read-only from most of the app; the
/// storefront checkout flow is the main place that mutates a customer
/// (bumping `totalSpent`) after an order is placed.
final customersProvider =
    AsyncNotifierProvider<CustomersNotifier, List<Customer>>(CustomersNotifier.new);

class CustomersNotifier extends AsyncNotifier<List<Customer>> {
  @override
  Future<List<Customer>> build() {
    return ref.watch(customerRepositoryProvider).getAll();
  }

  Future<void> recordSpend(String customerId, double amount) async {
    final customers = state.valueOrNull ?? await future;
    final customer = customers.firstWhere((c) => c.id == customerId, orElse: () => customers.first);
    final updated = customer.copyWith(totalSpent: customer.totalSpent + amount);
    await ref.read(customerRepositoryProvider).update(updated);
    state = await AsyncValue.guard(() => ref.read(customerRepositoryProvider).getAll());
  }
}
