import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_notification.dart';
import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';
import '../../../data/models/product.dart';
import '../../customers/application/customer_providers.dart';
import '../../notifications/application/notification_providers.dart';
import '../../products/application/product_providers.dart';
import '../../../core/utils/id_generator.dart';
import 'order_providers.dart';

/// Interval between automatic orders (in seconds).
/// Default: 120 s (2 minutes). Adjust as desired.
const _intervalSeconds = 120;

/// Riverpod provider that keeps the auto-order timer alive for as long as
/// a widget is watching it. Wire it up once in [BoutiqueApp] with
/// `ref.watch(autoOrderServiceProvider)` so it runs app-wide.
final autoOrderServiceProvider = Provider<AutoOrderService>((ref) {
  final service = AutoOrderService(ref);
  ref.onDispose(service.dispose);
  return service;
});

class AutoOrderService {
  AutoOrderService(this._ref) {
    _timer = Timer.periodic(
      const Duration(seconds: _intervalSeconds),
      (_) => _maybeGenerateOrder(),
    );
  }

  final Ref _ref;
  late final Timer _timer;

  static final _random = Random();

  void dispose() => _timer.cancel();

  Future<void> _maybeGenerateOrder() async {
    // Need active, in-stock products to generate an order.
    final products = _ref.read(productsProvider).valueOrNull ?? [];
    final active = products.where((p) => p.isActive && !p.isOutOfStock).toList();
    if (active.isEmpty) return;

    final customers = _ref.read(customersProvider).valueOrNull ?? [];
    if (customers.isEmpty) return;

    // Pick a random customer.
    final customer = customers[_random.nextInt(customers.length)];

    // Pick 1-3 random products (no duplicates).
    active.shuffle(_random);
    final itemCount = _random.nextInt(3) + 1; // 1, 2 or 3
    final picked = active.take(itemCount).toList();

    final items = picked.map((p) {
      final qty = _random.nextInt(2) + 1; // 1 or 2 units
      final price = p.hasDiscount ? p.discountPrice! : p.price;
      return OrderItem(
        productId: p.id,
        productName: p.name,
        unitPrice: price,
        quantity: qty,
      );
    }).toList();

    final id = IdGenerator.generate();
    final order = Order(
      id: id,
      orderNumber: '#${id.substring(0, 4).toUpperCase()}',
      customerId: customer.id,
      customerName: customer.name,
      items: items,
      status: OrderStatus.newOrder,
      createdAt: DateTime.now(),
    );

    await _ref.read(ordersProvider.notifier).addOrder(order);
    await _ref.read(customersProvider.notifier).recordSpend(
          customer.id,
          order.totalPrice,
        );
    await _ref.read(notificationsProvider.notifier).add(
          NotificationType.newOrder,
          '🛍️ Yeni sipariş geldi!',
          '${customer.name}, ${order.orderNumber} numaralı siparişi verdi — '
              '${items.length} ürün.',
        );
  }

  /// Trigger an order right now (useful for testing via a button).
  Future<void> triggerNow() => _maybeGenerateOrder();
}
