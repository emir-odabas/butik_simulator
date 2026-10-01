import 'package:flutter/material.dart';

import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';
import '../../../data/models/product.dart';

/// One badge: what it's called and the condition that unlocks it.
///
/// Unlock state is always derived live from the current product/order
/// lists (see achievement_providers.dart) rather than persisted — once a
/// condition like "10 products" is met it stays met, so there's nothing
/// to lose by recomputing it on every rebuild.
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool Function(List<Product> products, List<Order> orders) isUnlocked;
}

int _deliveredOrderCount(List<Order> orders) =>
    orders.where((o) => o.status == OrderStatus.delivered).length;

int _totalFavorites(List<Product> products) =>
    products.fold(0, (sum, p) => sum + p.favoriteCount);

int _totalViews(List<Product> products) =>
    products.fold(0, (sum, p) => sum + p.viewCount);

final List<AchievementDefinition> achievementDefinitions = [
  AchievementDefinition(
    id: 'first_sale',
    title: 'İlk Satış',
    description: 'İlk siparişini teslim ettin.',
    icon: Icons.celebration_outlined,
    isUnlocked: (products, orders) => _deliveredOrderCount(orders) >= 1,
  ),
  AchievementDefinition(
    id: 'orders_10',
    title: '10 Sipariş',
    description: '10 sipariş tamamladın.',
    icon: Icons.local_shipping_outlined,
    isUnlocked: (products, orders) => _deliveredOrderCount(orders) >= 10,
  ),
  AchievementDefinition(
    id: 'orders_100',
    title: '100 Sipariş',
    description: '100 sipariş tamamladın. Gerçek bir butik ustasısın!',
    icon: Icons.military_tech_outlined,
    isUnlocked: (products, orders) => _deliveredOrderCount(orders) >= 100,
  ),
  AchievementDefinition(
    id: 'first_10_products',
    title: 'İlk 10 Ürün',
    description: 'Mağazana 10 ürün ekledin.',
    icon: Icons.checkroom_outlined,
    isUnlocked: (products, orders) => products.length >= 10,
  ),
  AchievementDefinition(
    id: 'popular_boutique',
    title: 'Popüler Butik',
    description: 'Ürünlerin toplam 500 kez görüntülendi.',
    icon: Icons.trending_up_outlined,
    isUnlocked: (products, orders) => _totalViews(products) >= 500,
  ),
  AchievementDefinition(
    id: 'favorites_100',
    title: '100 Favori',
    description: 'Ürünlerin toplamda 100 kez favorilendi.',
    icon: Icons.favorite_outline,
    isUnlocked: (products, orders) => _totalFavorites(products) >= 100,
  ),
  AchievementDefinition(
    id: 'big_discount',
    title: 'Büyük İndirim',
    description: 'Bir üründe %30 veya daha fazla indirim uyguladın.',
    icon: Icons.local_offer_outlined,
    isUnlocked: (products, orders) => products.any(
      (p) => p.hasDiscount && p.discountPrice! <= p.price * 0.7,
    ),
  ),
  AchievementDefinition(
    id: 'night_owl',
    title: 'Gece Kuşu',
    description: 'Gece yarısından sonra bir ürün ekledin.',
    icon: Icons.nightlight_outlined,
    isUnlocked: (products, orders) =>
        products.any((p) => p.createdAt.hour >= 0 && p.createdAt.hour < 5),
  ),
  AchievementDefinition(
    id: 'collector',
    title: 'Koleksiyoncu',
    description: '5 farklı kategoride ürün ekledin.',
    icon: Icons.category_outlined,
    isUnlocked: (products, orders) => products.map((p) => p.category).toSet().length >= 5,
  ),
];
