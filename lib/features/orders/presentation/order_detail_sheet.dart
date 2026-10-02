import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/atelier_colors.dart';
import '../../../core/design/atelier_typography.dart';
import '../../../core/design/components/ledger_row.dart';
import '../../../core/design/components/wax_seal_stamp.dart';
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
    backgroundColor: Colors.transparent,
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

/// The order's detail, styled as a torn-off receipt: a strip of
/// perforation dots along the top (colored to match whatever sits
/// behind the sheet, so they read as punched holes), white receipt
/// paper below it.
class _OrderDetailSheet extends ConsumerWidget {
  const _OrderDetailSheet({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'tr_TR');

    final currentIndex = _progression.indexOf(order.status);
    final nextStatus = (currentIndex >= 0 && currentIndex < _progression.length - 1)
        ? _progression[currentIndex + 1]
        : null;
    final isFinal = order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          child: ColoredBox(
            color: atelier.paperSurface,
            child: Column(
              children: [
                _PerforationStrip(holeColor: atelier.paperSurface),
                Expanded(
                  child: ColoredBox(
                    color: Colors.white,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      children: [
                        Center(
                          child: Text(order.orderNumber, style: theme.textTheme.headlineSmall),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            dateFormat.format(order.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: WaxSealStamp(
                            label: order.status.label,
                            color: statusColor(context, order.status),
                            angle: 0,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        LedgerRow(
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, size: 18, color: atelier.ink),
                              const SizedBox(width: AppSpacing.sm),
                              Text(order.customerName, style: theme.textTheme.bodyLarge),
                            ],
                          ),
                        ),
                        for (final item in order.items)
                          LedgerRow(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.productName} × ${item.quantity}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  Money.format(item.lineTotal),
                                  style: AtelierTypography.ledger(color: atelier.ink, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        LedgerRow(
                          showDivider: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Toplam', style: theme.textTheme.titleSmall),
                              Text(
                                Money.format(order.totalPrice),
                                style: AtelierTypography.ledger(color: atelier.seal, fontSize: 19),
                              ),
                            ],
                          ),
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
                              foregroundColor: atelier.error,
                              side: BorderSide(color: atelier.error.withValues(alpha: 0.4)),
                            ),
                            onPressed: () {
                              ref
                                  .read(ordersProvider.notifier)
                                  .updateStatus(order, OrderStatus.cancelled);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Siparişi İptal Et'),
                          ),
                        ] else if (order.status == OrderStatus.delivered)
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: atelier.thread),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Bu sipariş tamamlandı ve mağazana kazanç sağladı.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A row of small circles the color of whatever sits behind the sheet,
/// sitting right at the seam where the white receipt begins — reading
/// as punched perforation holes without any [CustomPainter].
class _PerforationStrip extends StatelessWidget {
  const _PerforationStrip({required this.holeColor});

  final Color holeColor;

  static const _holeCount = 14;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _holeCount,
          (i) => Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: holeColor, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
