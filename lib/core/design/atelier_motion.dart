import 'package:flutter/animation.dart';

/// Shared motion constants for the Atelier Ledger design language.
///
/// Deliberately slower and always ease-out — never Material's default
/// bouncy spring — so movement reads as considered/handmade rather than
/// snappy/digital. Kept as plain constants (not a full animation
/// framework) so every use site stays a cheap, ordinary
/// [AnimatedContainer]/[AnimatedSlide]/[AnimationController] with no
/// extra abstraction layer.
class AtelierMotion {
  AtelierMotion._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);

  static const Curve curve = Curves.easeOutCubic;
}
