/// Stores how many levels the player has purchased for each store
/// upgrade (decoration, photo studio, warehouse, ...). Keyed by the
/// upgrade's [UpgradeDefinition.id]; an id missing from the map means
/// level 0 (not purchased yet).
abstract class UpgradeRepository {
  Future<Map<String, int>> getLevels();
  Future<void> setLevel(String upgradeId, int level);
}
