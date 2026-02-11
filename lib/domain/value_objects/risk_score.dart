/// Score de risque - objet valeur immuable.
class RiskScore {
  final double value; // 0.0 to 100.0
  final String category; // low, medium, high, critical
  final List<String> factors;
  final DateTime calculatedAt;

  RiskScore({
    required double value,
    this.factors = const [],
    DateTime? calculatedAt,
  })  : value = value.clamp(0.0, 100.0),
        category = _categorize(value),
        calculatedAt = calculatedAt ?? DateTime.now();

  static String _categorize(double score) {
    if (score >= 80) return 'critical';
    if (score >= 60) return 'high';
    if (score >= 30) return 'medium';
    return 'low';
  }

  bool get isAcceptable => value < 60;
  bool get requiresReview => value >= 60;
  bool get requiresBlock => value >= 90;

  RiskScore combine(RiskScore other) {
    return RiskScore(
      value: (value + other.value) / 2,
      factors: [...factors, ...other.factors],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RiskScore && value == other.value;

  @override
  int get hashCode => value.hashCode;

  Map<String, dynamic> toJson() => {
    'value': value, 'category': category, 'factors': factors,
    'calculatedAt': calculatedAt.toIso8601String(),
  };

  factory RiskScore.fromJson(Map<String, dynamic> json) {
    return RiskScore(
      value: (json['value'] as num).toDouble(),
      factors: List<String>.from(json['factors'] ?? []),
    );
  }
}
