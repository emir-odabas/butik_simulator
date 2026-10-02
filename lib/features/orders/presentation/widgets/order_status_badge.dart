import 'package:flutter/material.dart';

import '../../../../core/design/atelier_colors.dart';
import '../../../../data/models/order_status.dart';

/// Maps each order status to an Atelier palette token, reusing the same
/// five colors the index-tab navigation already cycles through so the
/// whole app reads from one consistent palette rather than raw
/// `Colors.blue`/`Colors.green` picks.
Color statusColor(BuildContext context, OrderStatus status) {
  final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;
  return switch (status) {
    OrderStatus.newOrder => atelier.ink,
    OrderStatus.preparing => atelier.gold,
    OrderStatus.shipped => atelier.seal,
    OrderStatus.delivered => atelier.thread,
    OrderStatus.cancelled => atelier.error,
  };
}
