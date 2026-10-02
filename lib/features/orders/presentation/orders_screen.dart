import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/atelier_colors.dart';
import '../../../core/design/atelier_typography.dart';
import '../../../core/design/components/ledger_page.dart';
import '../../../core/design/components/ledger_row.dart';
import '../../../core/design/components/wax_seal_stamp.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/order_providers.dart';
import 'order_detail_sheet.dart';
import 'widgets/order_status_badge.dart';

/// Order list as a ledger table: ruled rows (no cards), an ink-stamp
/// for status instead of a filled Chip. Orders arrive here from the
/// storefront checkout flow or the seed data on first launch.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Siparişler')),
      body: LedgerPage(
        child: ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('Siparişler yüklenemedi: $error'),
            ),
          ),
          data: (orders) {
            if (orders.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Henüz sipariş yok',
                  message: 'Müşteriler sipariş verdikçe burada listelenecek.',
                ),
              );
            }

            final sorted = [...orders]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final visible = _statusFilter == null
                ? sorted
                : sorted.where((o) => o.status.label == _statusFilter).toList();

            final statusLabels = sorted.map((o) => o.status.label).toSet().toList();
            final dateFormat = DateFormat('d MMM, HH:mm', 'tr_TR');

            return Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                if (statusLabels.length > 1)
                  _StatusFilterRow(
                    labels: statusLabels,
                    selected: _statusFilter,
                    onSelected: (label) => setState(() => _statusFilter = label),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Text(
                            'Bu durumda sipariş yok.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final order = visible[index];
                            final atelier =
                                Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;

                            return LedgerRow(
                              onTap: () => showOrderDetailSheet(context, order),
                              showDivider: index != visible.length - 1,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.orderNumber,
                                          style: AtelierTypography.ledger(
                                            color: atelier.ink,
                                            fontSize: 15,
                                          ).copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${order.customerName} · ${order.itemCount} ürün',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          dateFormat.format(order.createdAt),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        Money.format(order.totalPrice),
                                        style: AtelierTypography.ledger(
                                          color: atelier.ink,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      WaxSealStamp(
                                        label: order.status.label,
                                        color: statusColor(context, order.status),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({required this.labels, required this.selected, required this.onSelected});

  final List<String> labels;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _Tab(label: 'Tümü', isSelected: selected == null, onTap: () => onSelected(null)),
          for (final label in labels)
            _Tab(label: label, isSelected: selected == label, onTap: () => onSelected(label)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: Semantics(
        button: true,
        selected: isSelected,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? atelier.ink : atelier.inkMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 2,
                width: 20,
                color: isSelected ? atelier.seal : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
