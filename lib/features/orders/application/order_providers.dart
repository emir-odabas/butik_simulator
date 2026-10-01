import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money.dart';
import '../../../data/datasources/local/local_storage_providers.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';
import '../../../data/repositories/local/local_order_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../notifications/application/notification_providers.dart';
import '../../store/application/store_providers.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return LocalOrderRepository(ref.watch(localStorageServiceProvider));
});

final ordersProvider =
    AsyncNotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

class OrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() {
    return ref.watch(orderRepositoryProvider).getAll();
  }

  Future<void> addOrder(Order order) async {
    await ref.read(orderRepositoryProvider).add(order);
    state = await AsyncValue.guard(() => ref.read(orderRepositoryProvider).getAll());
  }

  /// Moves [order] to [newStatus]. If this is the first time the order
  /// reaches [OrderStatus.delivered], the store also earns virtual
  /// revenue and XP for it (see [StoreProfileNotifier.grantOrderReward]).
  Future<void> updateStatus(Order order, OrderStatus newStatus) async {
    final grantsReward = newStatus == OrderStatus.delivered && !order.rewardGranted;

    final updatedOrder = order.copyWith(
      status: newStatus,
      deliveredAt: newStatus == OrderStatus.delivered ? (order.deliveredAt ?? DateTime.now()) : order.deliveredAt,
      rewardGranted: grantsReward ? true : order.rewardGranted,
    );

    await ref.read(orderRepositoryProvider).update(updatedOrder);
    state = await AsyncValue.guard(() => ref.read(orderRepositoryProvider).getAll());

    if (grantsReward) {
      await ref.read(storeProfileProvider.notifier).grantOrderReward(
            revenue: updatedOrder.totalPrice,
            xpGain: 20 + updatedOrder.itemCount * 5,
          );
      await ref.read(notificationsProvider.notifier).add(
            NotificationType.orderCompleted,
            '💰 Sipariş tamamlandı',
            '${updatedOrder.orderNumber} teslim edildi, '
                '${Money.format(updatedOrder.totalPrice)} sanal gelir kazandın.',
          );
    }
  }
}
