import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/components/ledger_page.dart';
import '../../../core/design/components/ticket_coupon.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/coupon.dart';
import '../application/coupon_providers.dart';
import 'coupon_form_sheet.dart';

/// Coupons as physical tear-away tickets — no `Card`, no overflow
/// `PopupMenuButton` (that reads as software admin chrome); actions sit
/// directly under each ticket instead.
class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kuponlar')),
      body: LedgerPage(
        child: couponsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Kuponlar yüklenemedi: $error')),
          data: (coupons) {
            if (coupons.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: EmptyState(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Henüz kupon yok',
                  message: 'Müşterilerine özel bir indirim kodu kes.',
                  actionLabel: 'Kupon Oluştur',
                  onAction: () => showCouponFormSheet(context),
                ),
              );
            }

            final sorted = [...coupons]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              itemCount: sorted.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _CouponEntry(coupon: sorted[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCouponFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CouponEntry extends ConsumerWidget {
  const _CouponEntry({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final String statusLabel;
    if (coupon.isExhausted) {
      statusLabel = 'Tükendi';
    } else if (coupon.isActive) {
      statusLabel = 'Aktif';
    } else {
      statusLabel = 'Pasif';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TicketCoupon(
          code: coupon.code,
          discountPercent: coupon.discountPercent,
          usedCount: coupon.usedCount,
          usageLimit: coupon.usageLimit,
          isUsable: coupon.isUsable,
          statusLabel: statusLabel,
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => ref.read(couponsProvider.notifier).toggleActive(coupon),
              child: Text(coupon.isActive ? 'Pasife Al' : 'Aktive Et'),
            ),
            TextButton(
              onPressed: () => ref.read(couponsProvider.notifier).deleteCoupon(coupon.id),
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              child: const Text('Sil'),
            ),
          ],
        ),
      ],
    );
  }
}
