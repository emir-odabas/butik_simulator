import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/product.dart';
import '../application/statistics_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weeklyStats = ref.watch(weeklyStatsProvider);
    final topProducts = ref.watch(topProductsProvider);
    final mostViewed = ref.watch(mostViewedProductsProvider);

    final totalRevenue = weeklyStats.fold<double>(0, (sum, s) => sum + s.revenue);
    final totalOrders = weeklyStats.fold<int>(0, (sum, s) => sum + s.orderCount);
    final maxRevenue = weeklyStats.fold<double>(0, (max, s) => s.revenue > max ? s.revenue : max);

    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Son 7 gün satış',
                  value: Money.format(totalRevenue),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryTile(
                  label: 'Son 7 gün sipariş',
                  value: '$totalOrders',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Günlük Satış Grafiği', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: SizedBox(
                height: 180,
                child: maxRevenue == 0
                    ? Center(
                        child: Text('Henüz veri yok', style: theme.textTheme.bodySmall),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= weeklyStats.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final day = weeklyStats[index].date;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      '${day.day}/${day.month}',
                                      style: theme.textTheme.bodySmall,
                                    ),
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
                              color: theme.colorScheme.primary,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('En Çok Satan Ürünler', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _ProductRankCard(
            products: topProducts,
            valueBuilder: (p) => '${p.salesCount} satış',
            emptyMessage: 'Henüz satış verisi yok.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('En Çok Görüntülenen Ürünler', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _ProductRankCard(
            products: mostViewed,
            valueBuilder: (p) => '${p.viewCount} görüntülenme',
            emptyMessage: 'Henüz görüntülenme verisi yok.',
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _ProductRankCard extends StatelessWidget {
  const _ProductRankCard({
    required this.products,
    required this.valueBuilder,
    required this.emptyMessage,
  });

  final List<Product> products;
  final String Function(Product product) valueBuilder;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (products.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(emptyMessage, style: theme.textTheme.bodySmall),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < products.length; i++)
            ListTile(
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Text('${i + 1}', style: TextStyle(color: theme.colorScheme.primary)),
              ),
              title: Text(
                products[i].name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(valueBuilder(products[i]), style: theme.textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
