import 'package:flutter/material.dart';

import '../atelier_colors.dart';
import '../atelier_typography.dart';

/// A coupon rendered as a physical ticket stub: the code in large ledger
/// type, a dashed tear-line, a small side stub showing the discount.
/// Replaces a `Card` + colored status pill.
class TicketCoupon extends StatelessWidget {
  const TicketCoupon({
    super.key,
    required this.code,
    required this.discountPercent,
    required this.usedCount,
    required this.usageLimit,
    required this.isUsable,
    required this.statusLabel,
  });

  final String code;
  final double discountPercent;
  final int usedCount;
  final int usageLimit;
  final bool isUsable;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atelier = theme.extension<AtelierColors>() ?? AtelierColors.light;
    final tone = isUsable ? atelier.ink : atelier.inkMuted;

    // Tally dots for usage — capped so a high-limit coupon doesn't
    // print hundreds of dots.
    final dotCount = usageLimit.clamp(0, 10);
    final filledDots = usageLimit == 0
        ? 0
        : ((usedCount / usageLimit) * dotCount).round().clamp(0, dotCount);

    return Opacity(
      opacity: isUsable ? 1 : 0.6,
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(color: atelier.hairline)),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code,
                        style: AtelierTypography.ledger(color: tone, fontSize: 19),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          for (var i = 0; i < dotCount; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: Icon(
                                Icons.circle,
                                size: 6,
                                color: i < filledDots ? atelier.gold : atelier.hairline,
                              ),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            '$usedCount / $usageLimit kullanıldı',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(1, 100),
                painter: _DashedLinePainter(color: atelier.hairline),
              ),
              SizedBox(
                width: 72,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '%${discountPercent.toStringAsFixed(0)}',
                        style: AtelierTypography.ledger(color: atelier.seal, fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusLabel.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A vertical dashed tear-line between the coupon body and its stub.
/// One short, static, non-looping painter — cheap and, unlike a dotted
/// `Border`, not otherwise available as a plain decoration.
class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 3.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, (y + dash).clamp(0, size.height)), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => oldDelegate.color != color;
}
