import 'package:flutter/material.dart';

import '../../../../core/design/atelier_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Category filter shown as a row of divider labels — an underline
/// under the active one — rather than Material `ChoiceChip` pills.
class CategoryTabRow extends StatelessWidget {
  const CategoryTabRow({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  /// `null` in [categories] represents "Tümü" and is prepended
  /// automatically by the caller if wanted — this widget just renders
  /// whatever labels it's given.
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          _Tab(label: 'Tümü', isSelected: selected == null, onTap: () => onSelected(null)),
          for (final category in categories)
            _Tab(
              label: category,
              isSelected: selected == category,
              onTap: () => onSelected(category),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: Semantics(
        button: true,
        selected: isSelected,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? atelier.ink : atelier.inkMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 2,
                width: 20,
                color: isSelected ? atelier.seal : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
