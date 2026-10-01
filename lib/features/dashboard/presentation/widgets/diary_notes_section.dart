import 'package:flutter/material.dart';

import '../../../../core/design/atelier_colors.dart';
import '../../../../core/design/atelier_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money.dart';
import '../../../../data/models/store_profile.dart';

/// "Bugünün Sayfası" — today's numbers as the shop owner's own diary
/// entry, not a stats list. Short first-person notes of different
/// weight run down a notebook page with a red margin line on the left:
/// one large headline note, two regular notes, one quieter aside. No
/// icons, no dividers, no boxes.
///
/// Numbers are wrapped in `**` markers in the note templates below and
/// drawn in the typewriter "ledger" face, so they read as figures typed
/// into a handwritten sentence. Zero values get their own natural
/// sentence rather than "0 …".
class DiaryNotesSection extends StatelessWidget {
  const DiaryNotesSection({
    super.key,
    required this.profile,
    required this.activeProductCount,
    required this.totalProductCount,
  });

  final StoreProfile profile;
  final int activeProductCount;
  final int totalProductCount;

  static const _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  static const _weekdays = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar',
  ];

  // Written by hand rather than via intl so this screen needs no locale
  // data to render the date.
  static String _dateLabel(DateTime d) =>
      '${d.day} ${_months[d.month - 1]}, ${_weekdays[d.weekday - 1]}';

  String get _revenueNote => profile.todayRevenue > 0
      ? 'Bugün **${Money.format(profile.todayRevenue)}** sanal satış yaptım.'
      : 'Bugünün ilk satışını bekliyorum.';

  String get _ordersNote => profile.todayOrders > 0
      ? '**${profile.todayOrders}** sipariş geldi.'
      : 'Henüz sipariş gelmedi.';

  String get _attentionNote {
    final visitors = profile.visitorCount;
    final favorites = profile.favoriteCount;
    if (visitors > 0 && favorites > 0) {
      return 'Vitrine **$visitors** kişi göz attı, **$favorites** kişi favorilerine ekledi.';
    }
    if (visitors > 0) return 'Vitrine **$visitors** kişi göz attı.';
    if (favorites > 0) return 'Ürünlerim **$favorites** kez favorilendi.';
    return 'Vitrine henüz kimse uğramadı.';
  }

  String get _asideNote {
    final String shelf;
    if (totalProductCount == 0) {
      shelf = 'Vitrin henüz boş, ilk ürünü eklemeliyim.';
    } else if (activeProductCount == totalProductCount) {
      shelf = 'Vitrinde **$totalProductCount** ürünün hepsi satışta.';
    } else if (activeProductCount == 0) {
      shelf = 'Şu an satışta ürün yok (toplam **$totalProductCount**).';
    } else {
      shelf = 'Vitrinde **$activeProductCount** ürün satışta (toplam **$totalProductCount**).';
    }
    return profile.rating > 0
        ? '$shelf Mağaza puanım **${profile.rating.toStringAsFixed(1)}**.'
        : shelf;
  }

  /// Splits `text` on `**` and styles every odd segment as a figure.
  static TextSpan _spans(String text, TextStyle? figureStyle) {
    final parts = text.split('**');
    return TextSpan(
      children: [
        for (var i = 0; i < parts.length; i++)
          if (parts[i].isNotEmpty)
            TextSpan(text: parts[i], style: i.isOdd ? figureStyle : null),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

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
        const SizedBox(height: 2),
        Text(
          _dateLabel(DateTime.now()),
          style: AtelierTypography.annotation(color: atelier.ink, fontSize: 25),
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: atelier.seal.withValues(alpha: 0.4), width: 1.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  _spans(
                    _revenueNote,
                    AtelierTypography.ledger(color: atelier.seal, fontSize: 24),
                  ),
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text.rich(
                  _spans(
                    _ordersNote,
                    AtelierTypography.ledger(color: atelier.ink, fontSize: 17),
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text.rich(
                  _spans(
                    _attentionNote,
                    AtelierTypography.ledger(color: atelier.ink, fontSize: 17),
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text.rich(
                  _spans(
                    _asideNote,
                    AtelierTypography.ledger(color: atelier.inkMuted, fontSize: 14),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: atelier.inkMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
