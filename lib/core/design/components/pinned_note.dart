import 'package:flutter/material.dart';

import '../atelier_colors.dart';

/// A loose sheet of note paper taped to the page, used for content that
/// should read as a separate note rather than part of the flowing page
/// (daily quests, later notifications).
///
/// Deliberately *not* a card: no rounded corners, no outline. The sheet
/// is a slightly irregular polygon (edges a hair off-level, one corner
/// cut), tinted a touch warmer than the page, casting a soft shadow,
/// with a strip of washi tape running across its top edge.
///
/// The whole note is rotated by a very small angle. Flutter's
/// [Transform] moves hit-testing with painting, so taps land where the
/// content is drawn — nothing inside needs special handling.
///
/// Reserve [padding]'s top for the tape: the tape overlaps the top ~12px
/// of the sheet.
class PinnedNote extends StatelessWidget {
  const PinnedNote({
    super.key,
    required this.child,
    this.angle = -0.02,
    this.tapeColor,
    this.paperColor,
    this.padding = const EdgeInsets.fromLTRB(18, 26, 20, 20),
  });

  final Widget child;

  /// Rotation in radians. The default is roughly -1.1°.
  final double angle;

  final Color? tapeColor;

  /// Defaults to the page's raised-paper tone warmed slightly with gold.
  final Color? paperColor;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;
    final paper = paperColor ??
        Color.alphaBlend(atelier.gold.withValues(alpha: 0.13), atelier.paperSurface);
    final tape = tapeColor ?? atelier.gold;

    return Transform.rotate(
      angle: angle,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PhysicalShape(
            clipper: const _NoteSheetClipper(),
            color: paper,
            elevation: 2.5,
            shadowColor: atelier.ink,
            child: Padding(padding: padding, child: child),
          ),
          Positioned(
            top: -11,
            left: 34,
            child: Transform.rotate(
              angle: -0.07,
              child: ClipPath(
                clipper: const _TapeClipper(),
                child: Container(
                  width: 84,
                  height: 24,
                  color: tape.withValues(alpha: 0.62),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Note outline: top edge a hair off-level, bottom-right corner cut on
/// the diagonal, bottom edge slightly uneven. Fixed geometry, no state.
class _NoteSheetClipper extends CustomClipper<Path> {
  const _NoteSheetClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    const cut = 20.0;

    return Path()
      ..moveTo(0, 1.5)
      ..lineTo(w, 0)
      ..lineTo(w, h - cut)
      ..lineTo(w - cut, h - 2)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Washi-tape outline: a rectangle with small zigzag ends, like tape
/// torn off a roll.
class _TapeClipper extends CustomClipper<Path> {
  const _TapeClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    const teeth = 3;
    const depth = 3.0;
    final step = h / teeth;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0);
    for (var i = 1; i <= teeth; i++) {
      path.lineTo(i.isOdd ? w - depth : w, i * step);
    }
    for (var i = teeth; i >= 0; i--) {
      path.lineTo(i.isOdd ? depth : 0, i * step);
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
