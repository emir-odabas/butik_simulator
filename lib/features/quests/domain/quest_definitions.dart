import 'package:flutter/material.dart';

import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';
import '../../../data/models/product.dart';

bool _isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month && date.day == now.day;
}

/// One daily quest: what it asks for, what it rewards, and how its
/// current progress is computed from the live product/order lists.
///
/// Progress is always derived (never stored) so it can't drift out of
/// sync with the catalog/orders — only the "claimed today" flag is
/// persisted, in [QuestRepository].
class QuestDefinition {
  const QuestDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.xpReward,
    required this.coinReward,
    required this.progress,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int target;
  final int xpReward;
  final double coinReward;
  final int Function(List<Product> products, List<Order> orders) progress;
}

final List<QuestDefinition> dailyQuestDefinitions = [
  QuestDefinition(
    id: 'add_products_today',
    title: 'Bugün 2 ürün ekle',
    description: 'Mağazana yeni ürünler ekleyerek vitrinini tazele.',
    icon: Icons.add_box_outlined,
    target: 2,
    xpReward: 30,
    coinReward: 50,
    progress: (products, orders) => products.where((p) => _isToday(p.createdAt)).length,
  ),
  QuestDefinition(
    id: 'complete_orders_today',
    title: 'Bugün 1 sipariş tamamla',
    description: 'Bir siparişi "Teslim Edildi" durumuna getir.',
    icon: Icons.local_shipping_outlined,
    target: 1,
    xpReward: 40,
    coinReward: 80,
    progress: (products, orders) =>
        orders.where((o) => o.status == OrderStatus.delivered && o.deliveredAt != null && _isToday(o.deliveredAt!)).length,
  ),
  QuestDefinition(
    id: 'featured_products',
    title: '2 ürünü öne çıkar',
    description: 'Mağazanda en az 2 öne çıkan ürün bulunsun.',
    icon: Icons.star_outline,
    target: 2,
    xpReward: 20,
    coinReward: 30,
    progress: (products, orders) => products.where((p) => p.isFeatured).length,
  ),
];
