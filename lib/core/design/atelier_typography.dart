import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography for the Atelier Ledger design language.
///
/// Two fonts drive the app-wide [TextTheme] (readability comes first —
/// see the class doc on each): Fraunces for anything headline-sized,
/// Karla for everything meant to be actually read. Two more fonts are
/// exposed as standalone styles for deliberate, sparing use in specific
/// spots starting in later phases (prices/dates in [ledger], the odd
/// handwritten-style note in [annotation]) — they are never used for
/// body text or anywhere legibility matters most.
class AtelierTypography {
  AtelierTypography._();

  static TextTheme textTheme({required Color ink, required Color inkMuted}) {
    final display = GoogleFonts.frauncesTextTheme();
    final body = GoogleFonts.karlaTextTheme();

    TextStyle displayStyle(TextStyle? base, {FontWeight weight = FontWeight.w600}) =>
        (base ?? const TextStyle()).copyWith(color: ink, fontWeight: weight);

    TextStyle bodyStyle(TextStyle? base, {Color? color}) =>
        (base ?? const TextStyle()).copyWith(color: color ?? ink);

    return TextTheme(
      displayLarge: displayStyle(display.displayLarge),
      displayMedium: displayStyle(display.displayMedium),
      displaySmall: displayStyle(display.displaySmall),
      headlineLarge: displayStyle(display.headlineLarge),
      headlineMedium: displayStyle(display.headlineMedium),
      headlineSmall: displayStyle(display.headlineSmall),
      titleLarge: displayStyle(display.titleLarge, weight: FontWeight.w600),
      titleMedium: displayStyle(display.titleMedium, weight: FontWeight.w600),
      titleSmall: displayStyle(display.titleSmall, weight: FontWeight.w600),
      bodyLarge: bodyStyle(body.bodyLarge),
      bodyMedium: bodyStyle(body.bodyMedium),
      bodySmall: bodyStyle(body.bodySmall, color: inkMuted),
      labelLarge: bodyStyle(body.labelLarge)
          .copyWith(fontWeight: FontWeight.w600),
      labelMedium: bodyStyle(body.labelMedium, color: inkMuted),
      labelSmall: bodyStyle(body.labelSmall, color: inkMuted),
    );
  }

  /// The "defter/daktilo" number style — reserved for prices, stock
  /// counts, dates, order numbers. Never for paragraphs.
  static TextStyle ledger({required Color color, double fontSize = 14}) {
    return GoogleFonts.specialElite(color: color, fontSize: fontSize);
  }

  /// A handwritten-style accent for the rare "personal note" flourish.
  /// Used sparingly (at most once or twice per screen) — never for
  /// content the user actually needs to read carefully.
  static TextStyle annotation({required Color color, double fontSize = 18}) {
    return GoogleFonts.caveat(color: color, fontSize: fontSize, fontWeight: FontWeight.w600);
  }
}
