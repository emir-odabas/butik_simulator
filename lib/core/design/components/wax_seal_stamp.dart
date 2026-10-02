import 'package:flutter/material.dart';

/// A status label styled as a rubber ink stamp — a double outline ring,
/// letter-spaced caps, a slight fixed tilt, transparent center — rather
/// than a filled Material `Chip` pill. Used for order status now;
/// achievements reuse the same "stamp" visual language in a later phase.
class WaxSealStamp extends StatelessWidget {
  const WaxSealStamp({super.key, required this.label, required this.color, this.angle = -0.05});

  final String label;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ),
      ),
    );
  }
}
