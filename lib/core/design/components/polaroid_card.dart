import 'package:flutter/material.dart';

import '../atelier_colors.dart';

/// A product's "photo": a Polaroid-style frame — thicker bottom border,
/// a caption in that border, a small stable tilt. This is the one
/// surface reserved for products; nothing else in the app should look
/// like this, per the design system's "each section, its own material"
/// rule.
///
/// The tilt is derived deterministically from [seedKey] (typically the
/// product id), not `Random()` — so a card never changes angle between
/// rebuilds, and the same product always tilts the same way. The whole
/// frame rotates together via [Transform.rotate], which carries hit
/// testing along with painting, so taps land exactly where the card is
/// drawn — no separate hit-box handling needed.
class PolaroidCard extends StatelessWidget {
  const PolaroidCard({
    super.key,
    required this.seedKey,
    required this.imageUrl,
    required this.caption,
    this.cornerTag,
    this.cornerTagColor,
    this.dimmed = false,
    this.onTap,
  });

  final String seedKey;
  final String? imageUrl;

  /// Content shown in the bottom "frame" strip — typically name+price.
  final Widget caption;

  /// A short label pinned to the top-left corner (e.g. "YENİ"). Keep it
  /// to one label — a Polaroid is already a busy shape; stacking
  /// several badges on it reads as clutter, not detail.
  final String? cornerTag;
  final Color? cornerTagColor;

  /// Fades the whole card — used for inactive/out-of-stock products.
  final bool dimmed;

  final VoidCallback? onTap;

  double get _angle {
    // A stable pseudo-random value in roughly -2.5°..+2.5°, derived from
    // the id so it never changes between rebuilds.
    final bucket = seedKey.hashCode.abs() % 5;
    return (bucket - 2) * 0.0175;
  }

  @override
  Widget build(BuildContext context) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;

    return Transform.rotate(
      angle: _angle,
      child: Opacity(
        opacity: dimmed ? 0.55 : 1.0,
        child: Material(
          color: Colors.white,
          elevation: 2,
          shadowColor: atelier.ink,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: _PolaroidPhoto(url: imageUrl),
                      ),
                      if (cornerTag != null)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            color: (cornerTagColor ?? atelier.seal).withValues(alpha: 0.92),
                            child: Text(
                              cornerTag!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  caption,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PolaroidPhoto extends StatelessWidget {
  const _PolaroidPhoto({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;

    if (url == null || url!.isEmpty) {
      return _placeholder(atelier, icon: Icons.image_outlined);
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(atelier, loading: true);
      },
      errorBuilder: (context, error, stackTrace) =>
          _placeholder(atelier, icon: Icons.broken_image_outlined),
    );
  }

  Widget _placeholder(AtelierColors atelier, {IconData? icon, bool loading = false}) {
    return ColoredBox(
      color: atelier.paperSurface,
      child: Center(
        child: loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: atelier.inkMuted),
              )
            : Icon(icon, color: atelier.inkMuted),
      ),
    );
  }
}
