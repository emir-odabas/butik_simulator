import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../achievements/application/achievement_providers.dart';

class AchievementsSection extends ConsumerWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final achievements = ref.watch(achievementProgressProvider);
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Rozetler', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  '$unlockedCount / ${achievements.length}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.85,
              children: [
                for (final achievement in achievements)
                  _BadgeTile(achievement: achievement),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.achievement});

  final AchievementProgress achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = achievement.isUnlocked;
    final tint = unlocked ? theme.colorScheme.primary : theme.colorScheme.outline;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(achievement.definition.title),
          content: Text(
            unlocked
                ? achievement.definition.description
                : '${achievement.definition.description}\n\nBu rozet henüz kilitli.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: unlocked ? 0.14 : 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              unlocked ? achievement.definition.icon : Icons.lock_outline,
              color: tint,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement.definition.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: unlocked ? null : theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
