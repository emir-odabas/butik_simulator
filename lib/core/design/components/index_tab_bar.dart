import 'package:flutter/material.dart';

import '../atelier_colors.dart';
import '../atelier_motion.dart';

/// Bottom navigation styled as a notebook's index tabs.
///
/// Resting tabs are just an icon and a label sitting on the page. The
/// active tab is a small sheet of paper that rises a few pixels above
/// the rest of the bar, with a thin colored strip along its top edge
/// (the tab's "index color") and a soft shadow — it reads as a physical
/// paper tab, not a filled block. It is the same width as its slot, so
/// nothing large or heavy appears at the bottom of the screen.
///
/// Legibility: text and icons are always in the ink color, never the
/// accent, so contrast stays high on every tab (the gold accent would
/// not be readable as text). The accent only colors the decorative strip.
///
/// Performance: no CustomPainter and no clipper; the only animation is
/// an [AnimatedContainer] height change when the selection moves.
class IndexTabBar extends StatelessWidget {
  const IndexTabBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Height of a resting tab; also where the bar's top rule sits.
  static const double _restHeight = 58;

  /// How far the active tab rises above the rule.
  static const double _rise = 9;

  static const double _totalHeight = _restHeight + _rise;

  static const _tabs = [
    _TabSpec(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Ana Sayfa'),
    _TabSpec(icon: Icons.storefront_outlined, selectedIcon: Icons.storefront, label: 'Mağazam'),
    _TabSpec(icon: Icons.checkroom_outlined, selectedIcon: Icons.checkroom, label: 'Ürünler'),
    _TabSpec(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long, label: 'Siparişler'),
    _TabSpec(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;
    // Index colors per the approved plan: Ana Sayfa=ink, Mağazam=gold,
    // Ürünler=seal, Siparişler=thread, Profil=neutral.
    final accents = [atelier.ink, atelier.gold, atelier.seal, atelier.thread, atelier.inkMuted];

    return SizedBox(
      height: _totalHeight,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: _rise,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: atelier.hairline))),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _IndexTab(
                    spec: _tabs[i],
                    accent: accents[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndexTab extends StatelessWidget {
  const _IndexTab({
    required this.spec,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final _TabSpec spec;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;
    final foreground = selected ? atelier.ink : atelier.inkMuted;

    final tappable = Semantics(
      button: true,
      selected: selected,
      label: spec.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(selected ? spec.selectedIcon : spec.icon, color: foreground, size: 21),
                const SizedBox(height: 3),
                Text(
                  spec.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 10.5,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    const topRadius = BorderRadius.vertical(top: Radius.circular(5));

    final Widget tab = selected
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: atelier.paperSurface,
                borderRadius: topRadius,
                boxShadow: [
                  BoxShadow(
                    color: atelier.ink.withValues(alpha: 0.14),
                    blurRadius: 5,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: topRadius,
                child: Column(
                  children: [
                    Container(height: 3, color: accent),
                    Expanded(child: tappable),
                  ],
                ),
              ),
            ),
          )
        : tappable;

    return AnimatedContainer(
      duration: AtelierMotion.fast,
      curve: AtelierMotion.curve,
      height: selected ? IndexTabBar._totalHeight : IndexTabBar._restHeight,
      child: tab,
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
