import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/coupon.dart';
import '../application/coupon_providers.dart';
import 'coupon_form_sheet.dart';

class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kuponlar')),
      body: couponsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Kuponlar yüklenemedi: $error')),
        data: (coupons) {
          if (coupons.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: EmptyState(
                icon: Icons.confirmation_number_outlined,
                title: 'Henüz kupon yok',
                message: 'Müşterilerine özel bir indirim kodu oluştur.',
                actionLabel: 'Kupon Oluştur',
                onAction: () => showCouponFormSheet(context),
              ),
            );
          }

          final sorted = [...coupons]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sorted.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _CouponCard(coupon: sorted[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCouponFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CouponCard extends ConsumerWidget {
  const _CouponCard({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final String statusLabel;
    final Color statusColor;
    if (coupon.isExhausted) {
      statusLabel = 'Tükendi';
      statusColor = Colors.orange;
    } else if (coupon.isActive) {
      statusLabel = 'Aktif';
      statusColor = Colors.green;
    } else {
      statusLabel = 'Pasif';
      statusColor = Colors.grey;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Icon(Icons.confirmation_number_outlined, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coupon.code, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '%${coupon.discountPercent.toStringAsFixed(0)} indirim · '
                    '${coupon.usedCount}/${coupon.usageLimit} kullanıldı',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'toggle') {
                  ref.read(couponsProvider.notifier).toggleActive(coupon);
                } else if (value == 'delete') {
                  ref.read(couponsProvider.notifier).deleteCoupon(coupon.id);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(coupon.isActive ? 'Pasife Al' : 'Aktive Et'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Sil')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
