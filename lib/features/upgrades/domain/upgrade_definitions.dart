import 'package:flutter/material.dart';

/// One store upgrade the player can level up with virtual balance
/// (e.g. "Fotoğraf Stüdyosu"). Purely a progression sink for most
/// upgrades right now; a couple nudge a dashboard stat immediately (see
/// UpgradesNotifier.upgrade) so leveling up feels tangible even before
/// upgrades unlock real mechanical effects in a later phase.
class UpgradeDefinition {
  const UpgradeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.maxLevel,
    required this.baseCost,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int maxLevel;
  final double baseCost;

  /// Virtual cost to go from [currentLevel] to `currentLevel + 1`.
  /// Scales linearly so each level costs noticeably more than the last.
  double costForLevel(int currentLevel) => baseCost * (currentLevel + 1);
}

final List<UpgradeDefinition> upgradeDefinitions = [
  UpgradeDefinition(
    id: 'decoration',
    title: 'Dekorasyon',
    description: 'Mağazanı görsel olarak zenginleştir.\n(Etki: Siparişlerde ürün adetini artırır)',
    icon: Icons.local_florist_outlined,
    maxLevel: 5,
    baseCost: 200,
  ),
  UpgradeDefinition(
    id: 'premium_theme',
    title: 'Premium Tema',
    description: 'Butiğine özel, daha şık bir görünüm aç.\n(Etki: Satılan ürünlerin fiyatını %5 artırır)',
    icon: Icons.auto_awesome_outlined,
    maxLevel: 5,
    baseCost: 400,
  ),
  UpgradeDefinition(
    id: 'photo_studio',
    title: 'Fotoğraf Stüdyosu',
    description: 'Ürün fotoğraflarının kalitesini yükselt.\n(Etki: Her üründe viral satış (2x adet) ihtimali ekler)',
    icon: Icons.camera_alt_outlined,
    maxLevel: 5,
    baseCost: 300,
  ),
  UpgradeDefinition(
    id: 'warehouse',
    title: 'Depo',
    description: 'Daha fazla stok tutma kapasitesi kazan.\n(Etki: Siparişlerdeki ürün çeşitliliğini artırır)',
    icon: Icons.warehouse_outlined,
    maxLevel: 5,
    baseCost: 250,
  ),
  UpgradeDefinition(
    id: 'showcase',
    title: 'Vitrin',
    description: 'Öne çıkan ürünlerini daha etkili sergile.\n(Etki: Müşterilerin sipariş verme sıklığını hızlandırır)',
    icon: Icons.storefront_outlined,
    maxLevel: 5,
    baseCost: 350,
  ),
  UpgradeDefinition(
    id: 'advertising',
    title: 'Reklam',
    description: 'Mağazana daha fazla ziyaretçi çek.\n(Etki: Sipariş geldiğinde çifte sipariş gelme şansını artırır)',
    icon: Icons.campaign_outlined,
    maxLevel: 5,
    baseCost: 300,
  ),
  UpgradeDefinition(
    id: 'customer_service',
    title: 'Müşteri Hizmetleri',
    description: 'Müşteri memnuniyetini ve mağaza puanını artır.\n(Etki: Satışlardan ekstra bahşiş/prim geliri sağlar)',
    icon: Icons.support_agent_outlined,
    maxLevel: 5,
    baseCost: 200,
  ),
];
