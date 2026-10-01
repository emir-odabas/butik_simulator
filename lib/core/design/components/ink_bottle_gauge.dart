import 'package:flutter/material.dart';

import '../atelier_colors.dart';

/// A small ink-bottle silhouette that fills up to represent XP progress,
/// replacing a generic [LinearProgressIndicator].
///
/// Performance: the painter only redraws while [progress] is actively
/// animating between two values (driven by [TweenAnimationBuilder], not
/// a free-running [AnimationController]) — at rest it paints once and
/// sits idle. The bottle silhouette itself is a handful of fixed
/// path/arc operations, not a loop over generated geometry.
class InkBottleGauge extends StatelessWidget {
  const InkBottleGauge({
    super.key,
    required this.progress,
    this.size = 56,
  });

  /// 0.0–1.0 fill level.
  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final atelier = Theme.of(context).extension<AtelierColors>() ?? AtelierColors.light;
    final clamped = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size * 0.8,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: clamped, end: clamped),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            painter: _InkBottlePainter(
              progress: value,
              outline: atelier.ink,
              glass: atelier.paperSurface,
              ink: atelier.gold,
            ),
          );
        },
      ),
    );
  }
}

class _InkBottlePainter extends CustomPainter {
  const _InkBottlePainter({
    required this.progress,
    required this.outline,
    required this.glass,
    required this.ink,
  });

  final double progress;
  final Color outline;
  final Color glass;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body: a rounded-corner jar occupying the bottom ~70% of the
    // height. Neck: a narrower rect on top. Both fixed proportions of
    // the given size — no randomness, nothing generated in a loop.
    final bodyTop = h * 0.34;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, bodyTop, w, h - bodyTop),
      Radius.circular(w * 0.18),
    );

    final neckRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.30, 0, w * 0.40, bodyTop + 2),
      topLeft: Radius.circular(w * 0.08),
      topRight: Radius.circular(w * 0.08),
    );

    // One clean union silhouette, so the neck/body seam doesn't stroke
    // as a doubled line.
    final bodyPath = Path.combine(
      PathOperation.union,
      Path()..addRRect(bodyRect),
      Path()..addRRect(neckRect),
    );

    // Glass background.
    canvas.drawPath(bodyPath, Paint()..color = glass);

    // Ink fill, clipped to the jar silhouette, drawn from the bottom up.
    if (progress > 0) {
      canvas.save();
      canvas.clipPath(bodyPath);
      final fillHeight = (h - bodyTop) * progress;
      final fillTop = h - fillHeight;
      canvas.drawRect(Rect.fromLTWH(0, fillTop, w, fillHeight), Paint()..color = ink);
      // A faint lighter line at the ink's surface for a subtle meniscus.
      if (progress < 0.98) {
        canvas.drawRect(
          Rect.fromLTWH(0, fillTop, w, 1.4),
          Paint()..color = ink.withValues(alpha: 0.5),
        );
      }
      canvas.restore();
    }

    // Outline on top.
    final strokePaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(bodyPath, strokePaint);

    // Small cap line at the neck opening.
    canvas.drawLine(
      Offset(w * 0.30, 1),
      Offset(w * 0.70, 1),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _InkBottlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.outline != outline ||
        oldDelegate.ink != ink;
  }
}
