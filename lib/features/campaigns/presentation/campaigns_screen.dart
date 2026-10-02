import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/atelier_colors.dart';
import '../../../core/design/components/ledger_page.dart';
import '../../../core/design/components/pinned_note.dart';
import '../../../core/design/components/wax_seal_stamp.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/campaign.dart';
import '../application/campaign_providers.dart';
import 'campaign_form_sheet.dart';

/// Campaigns as a small corkboard: each one is a [PinnedNote], tilted a
/// little differently (deterministically, from the campaign id) so the
/// list reads as notes pinned down a board rather than a repeated card.
class CampaignsScreen extends ConsumerWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(campaignsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kampanyalar')),
      body: LedgerPage(
        child: campaignsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Kampanyalar yüklenemedi: $error')),
          data: (campaigns) {
            if (campaigns.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: EmptyState(
                  icon: Icons.push_pin_outlined,
                  title: 'Pano henüz boş',
                  message: 'Müşterilerini çekmek için ilk kampanyanı iğnele.',
                  actionLabel: 'Kampanya Oluştur',
                  onAction: () => showCampaignFormSheet(context),
                ),
              );
            }

            final sorted = [...campaigns]..sort((a, b) => b.startDate.compareTo(a.startDate));

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final campaign = sorted[index];
                // A small, stable per-card tilt — even indices lean one
                // way, odd the other — so the board doesn't look uniform.
                final angle = (campaign.id.hashCode.isEven ? -1 : 1) * 0.018;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: PinnedNote(
                    angle: angle,
                    child: _CampaignNoteContent(campaign: campaign),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCampaignFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CampaignNoteContent extends ConsumerWidget {
  const _CampaignNoteContent({required this.campaign});

  final Campaign campaign;

  static const _months = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];
  static String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    final String statusLabel;
    final Color stampColor;
    if (!campaign.isEnabled) {
      statusLabel = 'Pasif';
      stampColor = atelier.inkMuted;
    } else if (campaign.isCurrentlyActive) {
      statusLabel = 'Aktif';
      stampColor = atelier.thread;
    } else if (campaign.isUpcoming) {
      statusLabel = 'Yakında';
      stampColor = atelier.gold;
    } else {
      statusLabel = 'Süresi Doldu';
      stampColor = atelier.inkMuted;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(campaign.name, style: theme.textTheme.titleMedium)),
            WaxSealStamp(label: statusLabel, color: stampColor),
          ],
        ),
        if (campaign.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(campaign.description, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text(
              '%${campaign.discountPercent.toStringAsFixed(0)} indirim',
              style: theme.textTheme.titleSmall?.copyWith(color: atelier.seal),
            ),
            const Spacer(),
            Text(
              '${_fmt(campaign.startDate)} – ${_fmt(campaign.endDate)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => ref.read(campaignsProvider.notifier).toggleEnabled(campaign),
              child: Text(campaign.isEnabled ? 'Pasife Al' : 'Aktive Et'),
            ),
            TextButton(
              onPressed: () => ref.read(campaignsProvider.notifier).deleteCampaign(campaign.id),
              style: TextButton.styleFrom(foregroundColor: atelier.error),
              child: const Text('Sil'),
            ),
          ],
        ),
      ],
    );
  }
}
