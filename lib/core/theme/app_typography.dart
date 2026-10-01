import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens.
///
/// Pairing: 'Playfair Display' (serif, elegant) for headings that need to
/// feel boutique/editorial, with 'Inter' (clean grotesk) for body text and
/// UI chrome so long lists of numbers/stats stay easy to read.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color primaryText, Color secondaryText) {
    final base = GoogleFonts.interTextTheme();
    final display = GoogleFonts.playfairDisplayTextTheme();

    return base.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: primaryText),
      bodyMedium: base.bodyMedium?.copyWith(color: primaryText),
      bodySmall: base.bodySmall?.copyWith(color: secondaryText),
      labelLarge: base.labelLarge?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(color: secondaryText),
      labelSmall: base.labelSmall?.copyWith(color: secondaryText),
    );
  }
}
