import 'dart:math';

/// Generates short, unique-enough IDs for locally created records
/// (products, orders, etc.) without pulling in the `uuid` package.
///
/// Not cryptographically unique — fine for a local simulation where IDs
/// never need to be globally unique across devices/servers.
class IdGenerator {
  IdGenerator._();

  static final Random _random = Random();

  static String generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final randomPart = _random.nextInt(0x7FFFFFFF).toRadixString(36);
    return '$timestamp$randomPart';
  }
}
