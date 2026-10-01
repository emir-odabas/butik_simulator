/// App-wide constants shared across features.
///
/// Magic numbers/strings used in more than one place should live here
/// instead of being repeated inline.
class AppConstants {
  AppConstants._();

  static const String appName = 'Boutique Simulator';

  /// Default boutique name shown for a brand-new store, before the
  /// user renames it.
  static const String defaultStoreName = 'Moon Boutique';

  /// Reminder used across the UI to make clear that all money, sales
  /// and orders are part of the simulation, not real commerce.
  static const String virtualEconomyLabel = 'Sanal';
}
