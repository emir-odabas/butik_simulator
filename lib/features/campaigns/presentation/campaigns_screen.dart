import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/campaign.dart';
import '../application/campaign_providers.dart';
import 'campaign_form_sheet.dart';

class CampaignsScreen extends ConsumerWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(campaignsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kampanyalar')),
      body: campaignsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Kampanyalar yüklenemedi: $error')),
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: EmptyState(
                icon: Icons.local_offer_outlined,
                title: 'Henüz kampanya yok',
                message: 'Müşterilerini çekmek için ilk kampanyanı oluştur.',
                actionLabel: 'Kampanya Oluştur',
                onAction: () => showCampaignFormSheet(context),
              ),
            );
          }

          final sorted = [...campaigns]..sort((a, b) => b.startDate.compareTo(a.startDate));

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sorted.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _CampaignCard(campaign: sorted[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCampaignFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CampaignCard extends ConsumerWidget {
  const _CampaignCard({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFmt = DateFormatShort();

    final String statusLabel;
    final Color statusColor;
    if (!campaign.isEnabled) {
      statusLabel = 'Pasif';
      statusColor = Colors.grey;
    } else if (campaign.isCurrentlyActive) {
      statusLabel = 'Aktif';
      statusColor = Colors.green;
    } else if (campaign.isUpcoming) {
      statusLabel = 'Yakında';
      statusColor = Colors.blue;
    } else {
      statusLabel = 'Süresi Doldu';
      statusColor = Colors.orange;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(campaign.name, style: theme.textTheme.titleSmall)),
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
              ],
            ),
            if (campaign.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(campaign.description, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text('%${campaign.discountPercent.toStringAsFixed(0)} indirim',
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
                const Spacer(),
                Text(
                  '${dateFmt.format(campaign.startDate)} – ${dateFmt.format(campaign.endDate)}',
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
                  style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                  child: const Text('Sil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
