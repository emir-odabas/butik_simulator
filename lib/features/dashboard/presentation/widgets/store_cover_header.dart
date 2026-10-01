import 'package:flutter/material.dart';

import '../../../../core/design/atelier_colors.dart';
import '../../../../core/design/components/ink_bottle_gauge.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money.dart';
import '../../../../data/models/store_profile.dart';

/// The top of "Bugünün Sayfası" — a chapter cover, not a stat card.
/// Store identity reads like a book title; level is a small chapter
/// marker above it; XP is the [InkBottleGauge], not a progress bar.
class StoreCoverHeader extends StatelessWidget {
  const StoreCoverHeader({super.key, required this.profile});

  final StoreProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEVİYE ${profile.level}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: atelier.seal,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                profile.name,
                style: theme.textTheme.headlineMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _LogoRoundel(profile: profile),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // A hand-set rule under the title, with a small center ornament
        // instead of a plain Material Divider.
        Row(
          children: [
            Expanded(child: Divider(color: atelier.hairline, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Icon(Icons.circle, size: 4, color: atelier.hairline),
            ),
            Expanded(child: Divider(color: atelier.hairline, height: 1)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkBottleGauge(progress: profile.levelProgress, size: 52),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.xp} / ${profile.xpForNextLevel} mürekkep — '
                    'Seviye ${profile.level + 1} için',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 14, color: atelier.inkMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${Money.format(profile.virtualBalance)} sanal bakiye',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Small round store mark: the logo if there is one (falling back to a
/// monogram if the image fails to load), otherwise the store's initial.
class _LogoRoundel extends StatelessWidget {
  const _LogoRoundel({required this.profile});

  final StoreProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;
    final logoUrl = profile.logoUrl;

    Widget monogram() => Center(
          child: Text(
            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '•',
            style: theme.textTheme.titleMedium?.copyWith(color: atelier.ink),
          ),
        );

    return Container(
      width: 40,
      height: 40,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: atelier.paperSurface,
        shape: BoxShape.circle,
        border: Border.all(color: atelier.hairline),
      ),
      child: (logoUrl != null && logoUrl.isNotEmpty)
          ? Image.network(
              logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => monogram(),
            )
          : monogram(),
    );
  }
}
