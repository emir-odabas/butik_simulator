import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';
import '../../../data/models/product.dart';
import '../../orders/application/order_providers.dart';
import '../../products/application/product_providers.dart';

/// Revenue and order count for a single calendar day, used to draw the
/// last-7-days chart.
class DailyStat {
  const DailyStat({required this.date, required this.revenue, required this.orderCount});

  final DateTime date;
  final double revenue;
  final int orderCount;
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Revenue from delivered orders, bucketed by day, for the last 7 days
/// (oldest first).
final weeklyStatsProvider = Provider<List<DailyStat>>((ref) {
  final orders = ref.watch(ordersProvider).valueOrNull ?? const <Order>[];
  final delivered = orders.where((o) => o.status == OrderStatus.delivered && o.deliveredAt != null);

  final now = DateTime.now();
  return [
    for (var i = 6; i >= 0; i--)
      _statForDay(now.subtract(Duration(days: i)), delivered),
  ];
});

DailyStat _statForDay(DateTime day, Iterable<Order> deliveredOrders) {
  final ordersOnDay = deliveredOrders.where((o) => _sameDay(o.deliveredAt!, day));
  final revenue = ordersOnDay.fold<double>(0, (sum, o) => sum + o.totalPrice);
  return DailyStat(date: day, revenue: revenue, orderCount: ordersOnDay.length);
}

/// Top 5 products by simulated sales count.
final topProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider).valueOrNull ?? const <Product>[];
  final sorted = [...products]..sort((a, b) => b.salesCount.compareTo(a.salesCount));
  return sorted.take(5).toList();
});

/// Top 5 products by view count.
final mostViewedProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider).valueOrNull ?? const <Product>[];
  final sorted = [...products]..sort((a, b) => b.viewCount.compareTo(a.viewCount));
  return sorted.take(5).toList();
});
