import 'package:intl/intl.dart';

/// Formats virtual currency values consistently across the app.
///
/// Intentionally doesn't say "TL" is real money anywhere — screens that
/// show these values are responsible for labeling them as simulation
/// figures (see [AppConstants.virtualEconomyLabel]) where it matters.
class Money {
  Money._();

  static final _formatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  static String format(num value) => _formatter.format(value);
}
