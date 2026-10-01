import 'package:flutter/material.dart';

/// Centralized color tokens for the boutique app.
///
/// Palette direction: warm, muted neutrals with a soft rose/terracotta
/// accent — premium fashion-boutique feel rather than a generic admin
/// panel or a childish pastel-pink look.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFB8876B); // warm terracotta
  static const Color primaryLight = Color(0xFFE8D5C4);
  static const Color primaryDark = Color(0xFF8A5F45);

  static const Color accent = Color(0xFFD98E73); // soft blush accent
  static const Color success = Color(0xFF6E9A7C);
  static const Color warning = Color(0xFFD9A441);
  static const Color danger = Color(0xFFC96A5A);

  // Light theme neutrals
  static const Color lightBackground = Color(0xFFFAF7F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF2EDE8);
  static const Color lightBorder = Color(0xFFE7DFD8);
  static const Color lightTextPrimary = Color(0xFF2B2420);
  static const Color lightTextSecondary = Color(0xFF7A6F66);

  // Dark theme neutrals
  static const Color darkBackground = Color(0xFF17140F);
  static const Color darkSurface = Color(0xFF211D17);
  static const Color darkSurfaceMuted = Color(0xFF2A251E);
  static const Color darkBorder = Color(0xFF3A332A);
  static const Color darkTextPrimary = Color(0xFFF3ECE4);
  static const Color darkTextSecondary = Color(0xFFB3A79A);
}
