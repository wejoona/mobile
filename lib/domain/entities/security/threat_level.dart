/// Niveaux de menace pour le système de sécurité.
enum ThreatLevel {
  none('Aucune menace', 0),
  low('Menace faible', 1),
  elevated('Menace élevée', 2),
  high('Menace haute', 3),
  severe('Menace sévère', 4),
  critical('Menace critique', 5);

  final String description;
  final int numericValue;

  const ThreatLevel(this.description, this.numericValue);

  bool get requiresAction => numericValue >= 3;
  bool get shouldBlockOperations => numericValue >= 4;
  bool get requiresImmediateResponse => numericValue >= 5;

  /// Get threat level from numeric value.
  static ThreatLevel fromValue(int value) {
    return ThreatLevel.values.firstWhere(
      (t) => t.numericValue == value,
      orElse: () => ThreatLevel.none,
    );
  }

  /// Compare threat levels.
  bool isHigherThan(ThreatLevel other) => numericValue > other.numericValue;
}
