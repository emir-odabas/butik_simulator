import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/empty_state.dart';
import '../application/order_providers.dart';
import 'order_detail_sheet.dart';
import 'widgets/order_status_badge.dart';

/// Order management: list, filter by status, view detail, advance
/// status. Orders arrive here from the storefront checkout flow
/// (Phase 3) or from the seed data on first launch.
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
      body: ordersAsync.when(
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
              if (statusLabels.length > 1)
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    children: [
                      _FilterChip(
                        label: 'Tümü',
                        selected: _statusFilter == null,
                        onTap: () => setState(() => _statusFilter = null),
                      ),
                      for (final label in statusLabels)
                        _FilterChip(
                          label: label,
                          selected: _statusFilter == label,
                          onTap: () => setState(() => _statusFilter = label),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: visible.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final order = visible[index];
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => showOrderDetailSheet(context, order),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(order.orderNumber,
                                      style: Theme.of(context).textTheme.titleSmall),
                                  OrderStatusBadge(status: order.status),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${order.customerName} · ${order.itemCount} ürün',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(dateFormat.format(order.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall),
                                  Text(
                                    Money.format(order.totalPrice),
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
