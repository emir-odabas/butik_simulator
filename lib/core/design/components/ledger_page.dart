import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../atelier_colors.dart';

/// A paper-colored surface with a very faint, fixed grain texture.
///
/// This is the one deliberate [CustomPainter] use in the design system
/// for now — justified because this texture is the single most
/// identity-defining visual element of the whole "Atölye Defteri"
/// concept and appears behind nearly every surface in the app.
///
/// Performance notes:
/// - The dot positions are computed exactly once per app run (a
///   `static final` list), not per build.
/// - [_PaperGrainPainter.shouldRepaint] always returns false — the
///   grain never changes, so once painted for a given size it is never
///   repainted, and [RepaintBoundary] lets Flutter cache it as its own
///   composited layer.
/// - Only ~70 tiny circles are drawn; negligible even on first paint.
class LedgerPage extends StatelessWidget {
  const LedgerPage({super.key, required this.child, this.grainOpacity = 0.035});

  final Widget child;

  /// How visible the grain is. Kept subtle by default — this should
  /// read as "slightly textured paper", not "visibly dirty".
  final double grainOpacity;

  @override
  Widget build(BuildContext context) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;

    return DecoratedBox(
      decoration: BoxDecoration(color: atelier.paper),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _PaperGrainPainter(color: atelier.ink, opacity: grainOpacity),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PaperGrainPainter extends CustomPainter {
  const _PaperGrainPainter({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  static const _dotCount = 70;

  /// Fixed-seed, computed once — never regenerated, so the texture never
  /// "shifts" between rebuilds or app runs.
  static final List<Offset> _points = List.generate(_dotCount, (i) {
    final random = math.Random(1000 + i);
    return Offset(random.nextDouble(), random.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: opacity);
    for (final point in _points) {
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        0.6,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PaperGrainPainter oldDelegate) => false;
}
