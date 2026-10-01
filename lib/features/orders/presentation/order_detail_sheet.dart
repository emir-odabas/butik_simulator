import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';
import '../application/order_providers.dart';
import 'widgets/order_status_badge.dart';

Future<void> showOrderDetailSheet(BuildContext context, Order order) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _OrderDetailSheet(order: order),
  );
}

/// The forward-only progression an order normally moves through.
/// Cancellation is offered separately since it can happen from any
/// non-final state.
const _progression = [
  OrderStatus.newOrder,
  OrderStatus.preparing,
  OrderStatus.shipped,
  OrderStatus.delivered,
];

class _OrderDetailSheet extends ConsumerWidget {
  const _OrderDetailSheet({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'tr_TR');

    final currentIndex = _progression.indexOf(order.status);
    final nextStatus = (currentIndex >= 0 && currentIndex < _progression.length - 1)
        ? _progression[currentIndex + 1]
        : null;
    final isFinal = order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNumber, style: theme.textTheme.headlineSmall),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(dateFormat.format(order.createdAt), style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const CircleAvatar(radius: 18, child: Icon(Icons.person_outline, size: 18)),
                const SizedBox(width: AppSpacing.sm),
                Text(order.customerName, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Ürünler', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${item.productName} × ${item.quantity}',
                          style: theme.textTheme.bodyMedium),
                    ),
                    Text(Money.format(item.lineTotal), style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            const Divider(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Toplam', style: theme.textTheme.titleSmall),
                Text(Money.format(order.totalPrice), style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (!isFinal) ...[
              if (nextStatus != null)
                FilledButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref.read(ordersProvider.notifier).updateStatus(order, nextStatus);
                    Navigator.of(context).pop();
                  },
                  child: Text('${nextStatus.label} olarak işaretle'),
                ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                ),
                onPressed: () {
                  ref.read(ordersProvider.notifier).updateStatus(order, OrderStatus.cancelled);
                  Navigator.of(context).pop();
                },
                child: const Text('Siparişi İptal Et'),
              ),
            ] else if (order.status == OrderStatus.delivered)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text('Bu sipariş tamamlandı ve mağazana kazanç sağladı.'),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
