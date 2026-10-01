import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// A single stat tile used in the dashboard's stat grid
/// (today's revenue, orders, favorites, visitors, ...).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Icon(icon, size: 18, color: tint),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: theme.textTheme.titleMedium),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
