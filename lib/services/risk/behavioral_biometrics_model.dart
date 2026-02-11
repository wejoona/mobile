/// Modèle de biométrie comportementale.
///
/// Capture les patterns de comportement utilisateur
/// (vitesse de frappe, pression, gestes) pour détecter
/// les anomalies et prévenir la fraude.
class BehavioralBiometricProfile {
  final String userId;
  final TypingPattern? typingPattern;
  final TouchPattern? touchPattern;
  final NavigationPattern? navigationPattern;
  final DateTime capturedAt;

  const BehavioralBiometricProfile({
    required this.userId,
    this.typingPattern,
    this.touchPattern,
    this.navigationPattern,
    required this.capturedAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    if (typingPattern != null) 'typingPattern': typingPattern!.toJson(),
    if (touchPattern != null) 'touchPattern': touchPattern!.toJson(),
    if (navigationPattern != null) 'navigationPattern': navigationPattern!.toJson(),
    'capturedAt': capturedAt.toIso8601String(),
  };
}

class TypingPattern {
  final double avgKeystrokeInterval; // ms
  final double avgDwellTime; // ms
  final double typingSpeed; // caractères/min
  final double errorRate;

  const TypingPattern({
    required this.avgKeystrokeInterval,
    required this.avgDwellTime,
    required this.typingSpeed,
    required this.errorRate,
  });

  Map<String, dynamic> toJson() => {
    'avgKeystrokeInterval': avgKeystrokeInterval,
    'avgDwellTime': avgDwellTime,
    'typingSpeed': typingSpeed,
    'errorRate': errorRate,
  };
}

class TouchPattern {
  final double avgPressure;
  final double avgTouchArea;
  final double swipeSpeed;
  final String preferredHand; // left, right, unknown

  const TouchPattern({
    required this.avgPressure,
    required this.avgTouchArea,
    required this.swipeSpeed,
    this.preferredHand = 'unknown',
  });

  Map<String, dynamic> toJson() => {
    'avgPressure': avgPressure,
    'avgTouchArea': avgTouchArea,
    'swipeSpeed': swipeSpeed,
    'preferredHand': preferredHand,
  };
}

class NavigationPattern {
  final List<String> commonFlows;
  final double avgSessionDuration; // secondes
  final double avgScreenTime; // secondes par écran
  final int avgActionsPerSession;

  const NavigationPattern({
    this.commonFlows = const [],
    required this.avgSessionDuration,
    required this.avgScreenTime,
    required this.avgActionsPerSession,
  });

  Map<String, dynamic> toJson() => {
    'commonFlows': commonFlows,
    'avgSessionDuration': avgSessionDuration,
    'avgScreenTime': avgScreenTime,
    'avgActionsPerSession': avgActionsPerSession,
  };
}

/// Résultat de la comparaison biométrique
class BiometricMatchResult {
  final double confidence; // 0.0 - 1.0
  final bool isMatch;
  final List<String> anomalies;

  const BiometricMatchResult({
    required this.confidence,
    required this.isMatch,
    this.anomalies = const [],
  });
}
