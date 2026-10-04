import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/app_notification.dart';
import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';
import '../../customers/application/customer_providers.dart';
import '../../notifications/application/notification_providers.dart';
import '../../products/application/product_providers.dart';
import '../../../core/utils/id_generator.dart';
import '../../upgrades/application/upgrade_providers.dart';
import 'order_providers.dart';

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
    _scheduleNext();
  }

  final Ref _ref;
  Timer? _timer;

  static final _random = Random();

  void dispose() => _timer?.cancel();

  void _scheduleNext() {
    final levels = _ref.read(upgradeLevelsProvider).valueOrNull ?? {};
    final showcaseLvl = levels['showcase'] ?? 0;
    
    // Showcase (Vitrin) levels 0-5 decrease interval from 120s down to 20s
    final interval = max(20, 120 - (showcaseLvl * 20));

    _timer = Timer(Duration(seconds: interval), () async {
      await _maybeGenerateOrder();
      _scheduleNext();
    });
  }



  Future<void> _maybeGenerateOrder() async {
    // Need active, in-stock products to generate an order.
    final products = _ref.read(productsProvider).valueOrNull ?? [];
    final active = products.where((p) => p.isActive && !p.isOutOfStock).toList();
    if (active.isEmpty) return;

    final customers = _ref.read(customersProvider).valueOrNull ?? [];
    if (customers.isEmpty) return;

    // Pick a random customer.
    final customer = customers[_random.nextInt(customers.length)];

    final levels = _ref.read(upgradeLevelsProvider).valueOrNull ?? {};
    final warehouseLvl = levels['warehouse'] ?? 0;
    final decorationLvl = levels['decoration'] ?? 0;
    final premiumThemeLvl = levels['premium_theme'] ?? 0;
    final photoStudioLvl = levels['photo_studio'] ?? 0;
    final advertisingLvl = levels['advertising'] ?? 0;
    final customerServiceLvl = levels['customer_service'] ?? 0;

    // Pick random products. Warehouse increases variety (max items per order).
    active.shuffle(_random);
    final maxItems = 3 + warehouseLvl; // up to 8 different items
    final itemCount = _random.nextInt(maxItems) + 1; 
    final picked = active.take(itemCount).toList();

    final items = picked.map((p) {
      // Decoration increases unit quantity per item.
      final maxQty = 2 + decorationLvl; // up to 7 units per item
      var qty = _random.nextInt(maxQty) + 1; 

      // Photo Studio adds a chance (10% per level) to double the quantity (viral order)
      if (_random.nextDouble() < photoStudioLvl * 0.10) {
        qty *= 2;
      }

      final basePrice = p.hasDiscount ? p.discountPrice! : p.price;
      
      // Premium Theme increases base price (+5% per level)
      // Customer Service adds a flat tip (+5₺ per level)
      final priceMultiplier = 1.0 + (premiumThemeLvl * 0.05);
      final tip = customerServiceLvl * 5.0;
      final finalPrice = (basePrice * priceMultiplier) + tip;

      return OrderItem(
        productId: p.id,
        productName: p.name,
        unitPrice: finalPrice,
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

    // Advertising (Reklam) gives a chance to trigger another order immediately
    // 5% chance per level
    if (_random.nextDouble() < advertisingLvl * 0.05) {
      Future.delayed(const Duration(seconds: 1), _maybeGenerateOrder);
    }
  }

  /// Trigger an order right now (useful for testing via a button).
  Future<void> triggerNow() => _maybeGenerateOrder();
}
