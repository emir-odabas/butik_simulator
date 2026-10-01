import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order.dart';
import '../../../data/models/product.dart';
import '../../orders/application/order_providers.dart';
import '../../products/application/product_providers.dart';
import '../domain/achievement_definitions.dart';

class AchievementProgress {
  const AchievementProgress({required this.definition, required this.isUnlocked});

  final AchievementDefinition definition;
  final bool isUnlocked;
}

final achievementProgressProvider = Provider<List<AchievementProgress>>((ref) {
  final products = ref.watch(productsProvider).valueOrNull ?? const <Product>[];
  final orders = ref.watch(ordersProvider).valueOrNull ?? const <Order>[];

  return [
    for (final def in achievementDefinitions)
      AchievementProgress(definition: def, isUnlocked: def.isUnlocked(products, orders)),
  ];
});
