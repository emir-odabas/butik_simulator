import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'atelier_colors.dart';
import 'atelier_typography.dart';

/// Builds the app's [ThemeData] from the Atelier Ledger tokens.
///
/// Two things happen here:
/// 1. An [AtelierColors] [ThemeExtension] is attached, for the new
///    bespoke components (`core/design/components/*`) to read from
///    directly via `Theme.of(context).extension<AtelierColors>()`.
/// 2. A conventional [ColorScheme] is *also* derived from the same
///    tokens (via [ColorScheme.fromSeed] then overridden), purely so
///    the many existing Material widgets already used throughout the
///    app (buttons, switches, dialogs, chips, form fields) keep
///    resolving to well-contrasted colors without every screen needing
///    to be rewritten in this same pass. Per the approved plan, this UI
///    layer is being migrated screen by screen, not all at once.
class AtelierTheme {
  AtelierTheme._();

  static ThemeData light() => _build(AtelierColors.light, Brightness.light);

  static ThemeData dark() => _build(AtelierColors.dark, Brightness.dark);

  static ThemeData _build(AtelierColors atelier, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: atelier.seal,
      brightness: brightness,
      primary: atelier.seal,
      onPrimary: atelier.onSeal,
      secondary: atelier.gold,
      onSecondary: atelier.onGold,
      surface: atelier.paperSurface,
      onSurface: atelier.ink,
      error: atelier.error,
      outline: atelier.hairline,
    );

    final textTheme = AtelierTypography.textTheme(ink: atelier.ink, inkMuted: atelier.inkMuted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: atelier.paper,
      textTheme: textTheme,
      extensions: [atelier],
      appBarTheme: AppBarTheme(
        backgroundColor: atelier.paper,
        foregroundColor: atelier.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: atelier.paperSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: atelier.hairline),
        ),
      ),
      dividerTheme: DividerThemeData(color: atelier.hairline, space: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: atelier.seal,
          foregroundColor: atelier.onSeal,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: atelier.seal,
          foregroundColor: atelier.onSeal,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: atelier.ink,
          side: BorderSide(color: atelier.hairline),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: atelier.seal, textStyle: textTheme.labelLarge),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: atelier.paperSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: atelier.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: atelier.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: atelier.seal, width: 1.5),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: atelier.paperSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: atelier.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: atelier.paper),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
  }
}
