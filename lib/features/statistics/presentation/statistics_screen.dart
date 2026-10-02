import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/atelier_colors.dart';
import '../../../core/design/atelier_typography.dart';
import '../../../core/design/components/ledger_page.dart';
import '../../../core/design/components/ledger_row.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/product.dart';
import '../application/statistics_providers.dart';

/// "Satış Notları" — the week's numbers written as a page of the
/// owner's own notebook: a couple of sentences, a plain chart sitting
/// directly on the paper, and ranked product lists as ledger lines.
/// No KPI cards, no `Card`-wrapped chart, no `CircleAvatar` rank badges.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;
    final weeklyStats = ref.watch(weeklyStatsProvider);
    final topProducts = ref.watch(topProductsProvider);
    final mostViewed = ref.watch(mostViewedProductsProvider);

    final totalRevenue = weeklyStats.fold<double>(0, (sum, s) => sum + s.revenue);
    final totalOrders = weeklyStats.fold<int>(0, (sum, s) => sum + s.orderCount);
    final maxRevenue = weeklyStats.fold<double>(0, (max, s) => s.revenue > max ? s.revenue : max);

    return Scaffold(
      appBar: AppBar(title: const Text('Satış Notları')),
      body: LedgerPage(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              'SON 7 GÜN',
              style: theme.textTheme.labelMedium?.copyWith(
                color: atelier.inkMuted,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text.rich(
              TextSpan(
                style: theme.textTheme.titleLarge,
                children: [
                  const TextSpan(text: 'Bu hafta '),
                  TextSpan(
                    text: Money.format(totalRevenue),
                    style: AtelierTypography.ledger(color: atelier.seal, fontSize: 20),
                  ),
                  const TextSpan(text: ' sanal satış, '),
                  TextSpan(
                    text: '$totalOrders sipariş',
                    style: AtelierTypography.ledger(color: atelier.ink, fontSize: 20),
                  ),
                  const TextSpan(text: ' aldım.'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'GÜNLÜK SATIŞ ÇİZGİSİ',
              style: theme.textTheme.labelMedium?.copyWith(
                color: atelier.inkMuted,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 170,
              child: maxRevenue == 0
                  ? Center(child: Text('Henüz veri yok', style: theme.textTheme.bodySmall))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= weeklyStats.length) {
                                  return const SizedBox.shrink();
                                }
                                final day = weeklyStats[index].date;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text('${day.day}/${day.month}', style: theme.textTheme.bodySmall),
                                );
                              },
                            ),
                          ),
                        ),
                        minY: 0,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < weeklyStats.length; i++)
                                FlSpot(i.toDouble(), weeklyStats[i].revenue),
                            ],
                            isCurved: true,
                            color: atelier.seal,
                            barWidth: 2,
                            dotData: FlDotData(
                              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                radius: 3,
                                color: atelier.seal,
                                strokeColor: atelier.paper,
                                strokeWidth: 1,
                              ),
                            ),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _RankedList(
              label: 'EN ÇOK SATAN ÜRÜNLER',
              products: topProducts,
              valueBuilder: (p) => '${p.salesCount} satış',
              emptyMessage: 'Henüz satış verisi yok.',
            ),
            const SizedBox(height: AppSpacing.xl),
            _RankedList(
              label: 'EN ÇOK GÖRÜNTÜLENEN ÜRÜNLER',
              products: mostViewed,
              valueBuilder: (p) => '${p.viewCount} görüntülenme',
              emptyMessage: 'Henüz görüntülenme verisi yok.',
            ),
          ],
        ),
      ),
    );
  }
}

class _RankedList extends StatelessWidget {
  const _RankedList({
    required this.label,
    required this.products,
    required this.valueBuilder,
    required this.emptyMessage,
  });

  final String label;
  final List<Product> products;
  final String Function(Product product) valueBuilder;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: atelier.inkMuted, letterSpacing: 1.8),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (products.isEmpty)
          Text(emptyMessage, style: theme.textTheme.bodySmall)
        else
          for (var i = 0; i < products.length; i++)
            LedgerRow(
              showDivider: i != products.length - 1,
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${i + 1}.',
                      style: AtelierTypography.ledger(color: atelier.inkMuted, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      products[i].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(valueBuilder(products[i]), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
      ],
    );
  }
}
