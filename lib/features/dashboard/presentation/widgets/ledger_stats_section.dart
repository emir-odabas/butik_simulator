import 'package:flutter/material.dart';

import '../../../../core/design/atelier_colors.dart';
import '../../../../core/design/atelier_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money.dart';
import '../../../../data/models/store_profile.dart';

/// "Bugünün Sayfası" — today's numbers written as a short diary entry
/// instead of a grid of stat cards. One emphasized headline sentence
/// (today's revenue, in the ledger/typewriter numeral style), then a
/// column of smaller lines separated by hairline rules, like ruled
/// notebook paper. No boxes, no colored icon chips.
class LedgerStatsSection extends StatelessWidget {
  const LedgerStatsSection({
    super.key,
    required this.profile,
    required this.activeProductCount,
    required this.totalProductCount,
  });

  final StoreProfile profile;
  final int activeProductCount;
  final int totalProductCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    final lines = <_StatLine>[
      _StatLine(Icons.receipt_long_outlined, '${profile.todayOrders} sipariş geldi.'),
      _StatLine(Icons.visibility_outlined, '${profile.visitorCount} kişi mağazana baktı.'),
      _StatLine(Icons.favorite_outline, '${profile.favoriteCount} favori topladın.'),
      _StatLine(Icons.checkroom_outlined, '$activeProductCount / $totalProductCount ürün satışta.'),
      if (profile.rating > 0)
        _StatLine(Icons.star_outline, 'Mağaza puanın ${profile.rating.toStringAsFixed(1)}.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUGÜNÜN SAYFASI',
          style: theme.textTheme.labelMedium?.copyWith(
            color: atelier.inkMuted,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(
          TextSpan(
            style: theme.textTheme.titleLarge,
            children: [
              const TextSpan(text: 'Bugün '),
              TextSpan(
                text: Money.format(profile.todayRevenue),
                style: AtelierTypography.ledger(color: atelier.seal, fontSize: 21),
              ),
              const TextSpan(text: ' sanal satış yaptın.'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < lines.length; i++) ...[
          _LedgerLineRow(line: lines[i], ink: atelier.ink),
          if (i != lines.length - 1) Divider(color: atelier.hairline, height: AppSpacing.lg),
        ],
      ],
    );
  }
}

class _StatLine {
  const _StatLine(this.icon, this.text);

  final IconData icon;
  final String text;
}

class _LedgerLineRow extends StatelessWidget {
  const _LedgerLineRow({required this.line, required this.ink});

  final _StatLine line;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(line.icon, size: 17, color: ink),
          const SizedBox(width: 10),
          Expanded(child: Text(line.text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
