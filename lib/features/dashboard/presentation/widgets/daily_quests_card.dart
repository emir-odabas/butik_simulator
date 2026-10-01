import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/atelier_colors.dart';
import '../../../../core/design/atelier_typography.dart';
import '../../../../core/design/components/pinned_note.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../quests/application/quest_providers.dart';

/// Daily quests as a to-do note taped to the page. Only the heading is
/// handwritten; the items themselves stay in the regular body font so
/// they remain easy to read.
class DailyQuestsCard extends ConsumerWidget {
  const DailyQuestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;
    final quests = ref.watch(questProgressProvider);

    return PinnedNote(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Günün görevleri',
            style: AtelierTypography.annotation(color: atelier.ink, fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < quests.length; i++) ...[
            _QuestRow(quest: quests[i]),
            if (i != quests.length - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _QuestRow extends ConsumerWidget {
  const _QuestRow({required this.quest});

  final QuestProgress quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          quest.isClaimed ? Icons.check_box : Icons.check_box_outline_blank,
          size: 20,
          color: quest.isClaimed ? atelier.thread : atelier.ink,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quest.definition.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  decoration: quest.isClaimed ? TextDecoration.lineThrough : null,
                  color: quest.isClaimed ? atelier.inkMuted : atelier.ink,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  for (var i = 0; i < quest.definition.target; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.circle,
                        size: 7,
                        color: i < quest.current ? atelier.seal : atelier.hairline,
                      ),
                    ),
                  const SizedBox(width: 6),
                  Text('+${quest.definition.xpReward} XP', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
        if (!quest.isClaimed && quest.isCompleted)
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(claimedQuestsProvider.notifier).claim(quest.definition);
            },
            child: const Text('Al'),
          ),
      ],
    );
  }
}
