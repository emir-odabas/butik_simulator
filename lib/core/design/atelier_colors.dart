import 'package:flutter/material.dart';

/// Palette tokens for the "Atölye Defteri" (Atelier Ledger) design
/// language. Deliberately named after materials (paper, ink, wax seal,
/// thread) instead of Material's `primary`/`secondary` so component code
/// reads as design intent: `atelier.seal` for a call-to-action, not
/// `colorScheme.primary`.
///
/// A matching [ColorScheme] is still built in `atelier_theme.dart` from
/// these same tokens, purely so the many existing Material widgets
/// still in use (buttons, switches, dialogs, form fields) keep working
/// and stay well-contrasted without needing this whole app rewritten in
/// one pass.
@immutable
class AtelierColors extends ThemeExtension<AtelierColors> {
  const AtelierColors({
    required this.paper,
    required this.paperSurface,
    required this.ink,
    required this.inkMuted,
    required this.seal,
    required this.onSeal,
    required this.gold,
    required this.onGold,
    required this.thread,
    required this.hairline,
    required this.error,
  });

  /// Page/scaffold background — the "desk" the notebook sits on.
  final Color paper;

  /// Slightly lighter paper tone used for raised surfaces (cards, index
  /// cards, sheets) so they read as a sheet of paper sitting on the
  /// page, not a Material elevation shadow.
  final Color paperSurface;

  /// Primary text/ink color.
  final Color ink;

  /// Secondary/muted text.
  final Color inkMuted;

  /// Wax-seal red — the one warm accent used for CTAs, stamps and the
  /// active navigation tab.
  final Color seal;
  final Color onSeal;

  /// Gold-leaf accent — XP, rewards, highlights.
  final Color gold;
  final Color onGold;

  /// "Thread" green — positive/completed states (delivered orders, etc).
  final Color thread;

  /// Notebook rule-line color, used for hairline borders and dividers.
  final Color hairline;

  final Color error;

  static const light = AtelierColors(
    paper: Color(0xFFF7F1E8),
    paperSurface: Color(0xFFFFFBF3),
    ink: Color(0xFF2A2420),
    inkMuted: Color(0xFF6B5F52),
    seal: Color(0xFFB4472E),
    onSeal: Color(0xFFFBF3E7),
    gold: Color(0xFFC9A24B),
    onGold: Color(0xFF2A2420),
    thread: Color(0xFF6E8A5E),
    hairline: Color(0xFFDED2C0),
    error: Color(0xFFC1352B),
  );

  /// "Gece masası" (night desk) — a warm dark brown, never true black, so
  /// dark mode still feels like a physical desk after hours rather than
  /// a generic digital dark theme.
  static const dark = AtelierColors(
    paper: Color(0xFF1E1B16),
    paperSurface: Color(0xFF262019),
    ink: Color(0xFFF3ECE4),
    inkMuted: Color(0xFFB3A79A),
    seal: Color(0xFFC9573D),
    onSeal: Color(0xFF1E1B16),
    gold: Color(0xFFD4AF6A),
    onGold: Color(0xFF1E1B16),
    thread: Color(0xFF8AAE79),
    hairline: Color(0xFF3A332A),
    error: Color(0xFFD9695C),
  );

  @override
  AtelierColors copyWith({
    Color? paper,
    Color? paperSurface,
    Color? ink,
    Color? inkMuted,
    Color? seal,
    Color? onSeal,
    Color? gold,
    Color? onGold,
    Color? thread,
    Color? hairline,
    Color? error,
  }) {
    return AtelierColors(
      paper: paper ?? this.paper,
      paperSurface: paperSurface ?? this.paperSurface,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      seal: seal ?? this.seal,
      onSeal: onSeal ?? this.onSeal,
      gold: gold ?? this.gold,
      onGold: onGold ?? this.onGold,
      thread: thread ?? this.thread,
      hairline: hairline ?? this.hairline,
      error: error ?? this.error,
    );
  }

  @override
  AtelierColors lerp(ThemeExtension<AtelierColors>? other, double t) {
    if (other is! AtelierColors) return this;
    return AtelierColors(
      paper: Color.lerp(paper, other.paper, t)!,
      paperSurface: Color.lerp(paperSurface, other.paperSurface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      seal: Color.lerp(seal, other.seal, t)!,
      onSeal: Color.lerp(onSeal, other.onSeal, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      onGold: Color.lerp(onGold, other.onGold, t)!,
      thread: Color.lerp(thread, other.thread, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
