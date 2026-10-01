import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the app's current [ThemeMode].
///
/// The Atelier Ledger's main identity is the light "paper" theme, so the
/// app always opens in [ThemeMode.light] regardless of the phone's
/// system setting. The dark "Gece Masası" theme is kept as an
/// alternative the user can switch to on the Profile screen.
///
/// Exposed as a simple [StateProvider] for now; if the choice should
/// persist across app restarts, back this with local storage in a later
/// phase without changing how the rest of the app reads it.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
