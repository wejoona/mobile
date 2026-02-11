#!/bin/bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
BASE="lib/services"
mkdir -p $BASE/{risk,fraud,audit,privacy}

###############################################################################
# RUN 620: Device Risk Scoring Service
###############################################################################
cat > $BASE/risk/device_risk_scorer.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Score de risque de l'appareil
class DeviceRiskScore {
  final double score;
  final String level;
  final List<String> riskFactors;
  final bool isTrustedDevice;
  final DateTime scoredAt;

  const DeviceRiskScore({
    required this.score,
    required this.level,
    this.riskFactors = const [],
    this.isTrustedDevice = false,
    required this.scoredAt,
  });

  factory DeviceRiskScore.fromJson(Map<String, dynamic> json) => DeviceRiskScore(
    score: (json['score'] as num).toDouble(),
    level: json['level'] as String,
    riskFactors: List<String>.from(json['riskFactors'] ?? []),
    isTrustedDevice: json['isTrustedDevice'] as bool? ?? false,
    scoredAt: DateTime.now(),
  );
}

/// Service de scoring de risque de l'appareil.
///
/// Évalue la confiance accordée à l'appareil en fonction
/// de l'historique, l'intégrité et le comportement.
class DeviceRiskScorer {
  static const _tag = 'DeviceRiskScorer';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  DeviceRiskScorer({required Dio dio}) : _dio = dio;

  Future<DeviceRiskScore> scoreDevice({
    required String deviceId,
    required String platform,
    bool isRooted = false,
    bool isEmulator = false,
    bool hasDebugger = false,
    bool hasProxy = false,
  }) async {
    try {
      final response = await _dio.post('/risk/device/score', data: {
        'deviceId': deviceId,
        'platform': platform,
        'isRooted': isRooted,
        'isEmulator': isEmulator,
        'hasDebugger': hasDebugger,
        'hasProxy': hasProxy,
      });
      return DeviceRiskScore.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Device risk scoring failed', e);
      double score = 0.0;
      final factors = <String>[];
      if (isRooted) { score += 0.4; factors.add('Appareil rooté/jailbreaké'); }
      if (isEmulator) { score += 0.3; factors.add('Émulateur détecté'); }
      if (hasDebugger) { score += 0.2; factors.add('Débogueur attaché'); }
      if (hasProxy) { score += 0.1; factors.add('Proxy détecté'); }
      return DeviceRiskScore(
        score: score.clamp(0.0, 1.0),
        level: score > 0.7 ? 'high' : score > 0.3 ? 'medium' : 'low',
        riskFactors: factors,
        scoredAt: DateTime.now(),
      );
    }
  }
}

final deviceRiskScorerProvider = Provider<DeviceRiskScorer>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 621: Behavioral Biometrics Models
###############################################################################
cat > $BASE/risk/behavioral_biometrics_model.dart << 'DART'
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
DART

###############################################################################
# RUN 622: Behavioral Biometrics Collector
###############################################################################
cat > $BASE/risk/behavioral_biometrics_collector.dart << 'DART'
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'behavioral_biometrics_model.dart';

/// Collecteur de données biométriques comportementales.
///
/// Accumule les données de saisie, toucher et navigation
/// pour construire un profil comportemental.
class BehavioralBiometricsCollector {
  static const _tag = 'BiometricsCollector';
  final AppLogger _log = AppLogger(_tag);
  static const int _maxSamples = 100;

  final Queue<double> _keystrokeIntervals = Queue();
  final Queue<double> _dwellTimes = Queue();
  final Queue<double> _touchPressures = Queue();
  final Queue<String> _screenFlows = Queue();
  int _totalKeystrokes = 0;
  int _errorCount = 0;
  DateTime? _sessionStart;

  void recordKeystroke({required double intervalMs, required double dwellMs}) {
    _addSample(_keystrokeIntervals, intervalMs);
    _addSample(_dwellTimes, dwellMs);
    _totalKeystrokes++;
  }

  void recordTypingError() {
    _errorCount++;
  }

  void recordTouch({required double pressure}) {
    _addSample(_touchPressures, pressure);
  }

  void recordScreenVisit(String screenName) {
    if (_sessionStart == null) _sessionStart = DateTime.now();
    _screenFlows.addLast(screenName);
    if (_screenFlows.length > _maxSamples) _screenFlows.removeFirst();
  }

  void _addSample(Queue<double> queue, double value) {
    queue.addLast(value);
    if (queue.length > _maxSamples) queue.removeFirst();
  }

  double _average(Queue<double> queue) {
    if (queue.isEmpty) return 0.0;
    return queue.reduce((a, b) => a + b) / queue.length;
  }

  /// Générer le profil biométrique actuel
  BehavioralBiometricProfile generateProfile({required String userId}) {
    return BehavioralBiometricProfile(
      userId: userId,
      typingPattern: _keystrokeIntervals.isNotEmpty ? TypingPattern(
        avgKeystrokeInterval: _average(_keystrokeIntervals),
        avgDwellTime: _average(_dwellTimes),
        typingSpeed: _totalKeystrokes > 0 ? _totalKeystrokes / (_sessionDurationMin.clamp(0.1, double.infinity)) : 0,
        errorRate: _totalKeystrokes > 0 ? _errorCount / _totalKeystrokes : 0,
      ) : null,
      touchPattern: _touchPressures.isNotEmpty ? TouchPattern(
        avgPressure: _average(_touchPressures),
        avgTouchArea: 0.0,
        swipeSpeed: 0.0,
      ) : null,
      navigationPattern: NavigationPattern(
        commonFlows: _screenFlows.toList(),
        avgSessionDuration: _sessionDurationSec,
        avgScreenTime: _screenFlows.isNotEmpty ? _sessionDurationSec / _screenFlows.length : 0,
        avgActionsPerSession: _totalKeystrokes,
      ),
      capturedAt: DateTime.now(),
    );
  }

  double get _sessionDurationSec {
    if (_sessionStart == null) return 0;
    return DateTime.now().difference(_sessionStart!).inSeconds.toDouble();
  }

  double get _sessionDurationMin => _sessionDurationSec / 60.0;

  void reset() {
    _keystrokeIntervals.clear();
    _dwellTimes.clear();
    _touchPressures.clear();
    _screenFlows.clear();
    _totalKeystrokes = 0;
    _errorCount = 0;
    _sessionStart = null;
  }
}

final behavioralBiometricsCollectorProvider = Provider<BehavioralBiometricsCollector>((ref) {
  return BehavioralBiometricsCollector();
});
DART

###############################################################################
# RUN 623: Geo Risk Assessment Service
###############################################################################
cat > $BASE/risk/geo_risk_assessment_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Niveau de risque géographique
enum GeoRiskLevel { low, medium, high, prohibited }

/// Évaluation du risque géographique
class GeoRiskAssessment {
  final String countryCode;
  final GeoRiskLevel riskLevel;
  final double score;
  final List<String> reasons;
  final bool isProhibited;
  final DateTime assessedAt;

  const GeoRiskAssessment({
    required this.countryCode,
    required this.riskLevel,
    required this.score,
    this.reasons = const [],
    this.isProhibited = false,
    required this.assessedAt,
  });
}

/// Service d'évaluation du risque géographique.
///
/// Évalue le risque lié à la localisation de l'utilisateur
/// et des bénéficiaires selon les listes GAFI et UEMOA.
class GeoRiskAssessmentService {
  static const _tag = 'GeoRisk';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  // Pays à haut risque selon le GAFI (liste grise/noire)
  static const Set<String> _highRiskCountries = {
    'KP', 'IR', 'MM', 'SY', 'YE', 'AF',
  };

  // Pays UEMOA (risque réduit pour les transferts intra-zone)
  static const Set<String> _uemoaCountries = {
    'BJ', 'BF', 'CI', 'GW', 'ML', 'NE', 'SN', 'TG',
  };

  GeoRiskAssessmentService({required Dio dio}) : _dio = dio;

  /// Évaluer le risque géographique d'un pays
  Future<GeoRiskAssessment> assessCountry(String countryCode) async {
    // Vérification locale rapide
    if (_highRiskCountries.contains(countryCode)) {
      return GeoRiskAssessment(
        countryCode: countryCode,
        riskLevel: GeoRiskLevel.prohibited,
        score: 1.0,
        reasons: ['Pays sous sanctions internationales'],
        isProhibited: true,
        assessedAt: DateTime.now(),
      );
    }

    try {
      final response = await _dio.get('/risk/geo/$countryCode');
      final data = response.data as Map<String, dynamic>;
      return GeoRiskAssessment(
        countryCode: countryCode,
        riskLevel: GeoRiskLevel.values.byName(data['riskLevel'] as String),
        score: (data['score'] as num).toDouble(),
        reasons: List<String>.from(data['reasons'] ?? []),
        isProhibited: data['isProhibited'] as bool? ?? false,
        assessedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Geo risk assessment failed', e);
      final isUemoa = _uemoaCountries.contains(countryCode);
      return GeoRiskAssessment(
        countryCode: countryCode,
        riskLevel: isUemoa ? GeoRiskLevel.low : GeoRiskLevel.medium,
        score: isUemoa ? 0.1 : 0.4,
        assessedAt: DateTime.now(),
      );
    }
  }

  /// Vérifier si un transfert transfrontalier est autorisé
  Future<bool> isTransferAllowed({
    required String fromCountry,
    required String toCountry,
  }) async {
    final assessment = await assessCountry(toCountry);
    return !assessment.isProhibited;
  }

  bool isUemoaCountry(String countryCode) => _uemoaCountries.contains(countryCode);
}

final geoRiskAssessmentProvider = Provider<GeoRiskAssessmentService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 624: Velocity Risk Service
###############################################################################
cat > $BASE/risk/velocity_risk_service.dart << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Pattern de vélocité détecté
enum VelocityPattern {
  normal,
  accelerating,
  burst,
  structuring,
  roundTrip,
}

/// Évaluation du risque de vélocité
class VelocityRiskAssessment {
  final VelocityPattern pattern;
  final double riskScore;
  final String description;
  final Map<String, dynamic> metrics;
  final DateTime assessedAt;

  const VelocityRiskAssessment({
    required this.pattern,
    required this.riskScore,
    required this.description,
    this.metrics = const {},
    required this.assessedAt,
  });
}

/// Service d'évaluation du risque de vélocité.
///
/// Analyse les patterns de fréquence des transactions
/// pour détecter le structuring et autres comportements suspects.
class VelocityRiskService {
  static const _tag = 'VelocityRisk';
  final AppLogger _log = AppLogger(_tag);

  final List<_TransactionRecord> _recentTransactions = [];

  void recordTransaction({
    required double amount,
    required DateTime timestamp,
    required String recipientId,
  }) {
    _recentTransactions.add(_TransactionRecord(
      amount: amount, timestamp: timestamp, recipientId: recipientId,
    ));
    // Garder seulement les 30 derniers jours
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    _recentTransactions.removeWhere((t) => t.timestamp.isBefore(cutoff));
  }

  /// Évaluer le risque de vélocité actuel
  VelocityRiskAssessment assess() {
    if (_recentTransactions.isEmpty) {
      return VelocityRiskAssessment(
        pattern: VelocityPattern.normal,
        riskScore: 0.0,
        description: 'Aucune transaction récente',
        assessedAt: DateTime.now(),
      );
    }

    final now = DateTime.now();
    final last24h = _recentTransactions.where(
      (t) => now.difference(t.timestamp).inHours < 24).toList();
    final lastHour = last24h.where(
      (t) => now.difference(t.timestamp).inMinutes < 60).toList();

    double score = 0.0;
    var pattern = VelocityPattern.normal;
    final reasons = <String>[];

    // Burst: plus de 5 transactions en 1h
    if (lastHour.length > 5) {
      score += 0.4;
      pattern = VelocityPattern.burst;
      reasons.add('${lastHour.length} transactions en 1h');
    }

    // Structuring: montants juste en dessous du seuil
    final structuringThreshold = 4900000.0;
    final nearThreshold = last24h.where((t) =>
      t.amount > structuringThreshold * 0.8 && t.amount < structuringThreshold).length;
    if (nearThreshold >= 2) {
      score += 0.5;
      pattern = VelocityPattern.structuring;
      reasons.add('$nearThreshold transactions proches du seuil');
    }

    // Beaucoup de destinataires uniques
    final uniqueRecipients = last24h.map((t) => t.recipientId).toSet().length;
    if (uniqueRecipients > 10) {
      score += 0.3;
      reasons.add('$uniqueRecipients bénéficiaires uniques en 24h');
    }

    return VelocityRiskAssessment(
      pattern: pattern,
      riskScore: score.clamp(0.0, 1.0),
      description: reasons.isEmpty ? 'Activité normale' : reasons.join('; '),
      metrics: {
        'last24hCount': last24h.length,
        'lastHourCount': lastHour.length,
        'uniqueRecipients24h': uniqueRecipients,
      },
      assessedAt: now,
    );
  }

  void reset() => _recentTransactions.clear();
}

class _TransactionRecord {
  final double amount;
  final DateTime timestamp;
  final String recipientId;
  const _TransactionRecord({
    required this.amount, required this.timestamp, required this.recipientId,
  });
}

final velocityRiskProvider = Provider<VelocityRiskService>((ref) {
  return VelocityRiskService();
});
DART

###############################################################################
# RUN 625: Risk Decision Engine
###############################################################################
cat > $BASE/risk/risk_decision_engine.dart << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Décision du moteur de risque
enum RiskDecision { approve, challenge, review, decline }

/// Entrée composite pour le moteur de décision
class RiskInput {
  final double transactionRiskScore;
  final double deviceRiskScore;
  final double velocityRiskScore;
  final double geoRiskScore;
  final double amlRiskScore;
  final bool isPep;
  final bool isSanctioned;

  const RiskInput({
    this.transactionRiskScore = 0.0,
    this.deviceRiskScore = 0.0,
    this.velocityRiskScore = 0.0,
    this.geoRiskScore = 0.0,
    this.amlRiskScore = 0.0,
    this.isPep = false,
    this.isSanctioned = false,
  });
}

/// Résultat de la décision de risque
class RiskDecisionResult {
  final RiskDecision decision;
  final double compositeScore;
  final Map<String, double> scoreBreakdown;
  final List<String> reasons;
  final String? requiredAction;
  final DateTime decidedAt;

  const RiskDecisionResult({
    required this.decision,
    required this.compositeScore,
    this.scoreBreakdown = const {},
    this.reasons = const [],
    this.requiredAction,
    required this.decidedAt,
  });
}

/// Moteur de décision de risque.
///
/// Combine tous les scores de risque (transaction, appareil,
/// vélocité, géographique, AML) pour prendre une décision.
class RiskDecisionEngine {
  static const _tag = 'RiskDecision';
  final AppLogger _log = AppLogger(_tag);

  // Pondérations des facteurs
  static const _weights = {
    'transaction': 0.25,
    'device': 0.15,
    'velocity': 0.20,
    'geo': 0.15,
    'aml': 0.25,
  };

  /// Évaluer et prendre une décision
  RiskDecisionResult evaluate(RiskInput input) {
    // Sanctions = rejet immédiat
    if (input.isSanctioned) {
      return RiskDecisionResult(
        decision: RiskDecision.decline,
        compositeScore: 1.0,
        reasons: ['Entité sanctionnée'],
        decidedAt: DateTime.now(),
      );
    }

    final breakdown = {
      'transaction': input.transactionRiskScore,
      'device': input.deviceRiskScore,
      'velocity': input.velocityRiskScore,
      'geo': input.geoRiskScore,
      'aml': input.amlRiskScore,
    };

    double composite = 0.0;
    for (final entry in breakdown.entries) {
      composite += entry.value * (_weights[entry.key] ?? 0.0);
    }

    // PEP: augmenter le score
    if (input.isPep) composite = (composite + 0.2).clamp(0.0, 1.0);

    final reasons = <String>[];
    if (input.transactionRiskScore > 0.6) reasons.add('Risque transaction élevé');
    if (input.deviceRiskScore > 0.6) reasons.add('Risque appareil élevé');
    if (input.velocityRiskScore > 0.6) reasons.add('Vélocité suspecte');
    if (input.geoRiskScore > 0.6) reasons.add('Risque géographique');
    if (input.amlRiskScore > 0.6) reasons.add('Alerte AML');
    if (input.isPep) reasons.add('Personne politiquement exposée');

    RiskDecision decision;
    String? action;
    if (composite < 0.3) {
      decision = RiskDecision.approve;
    } else if (composite < 0.6) {
      decision = RiskDecision.challenge;
      action = 'Authentification supplémentaire requise';
    } else if (composite < 0.85) {
      decision = RiskDecision.review;
      action = 'Examen manuel requis';
    } else {
      decision = RiskDecision.decline;
      action = 'Transaction refusée';
    }

    return RiskDecisionResult(
      decision: decision,
      compositeScore: composite,
      scoreBreakdown: breakdown,
      reasons: reasons,
      requiredAction: action,
      decidedAt: DateTime.now(),
    );
  }
}

final riskDecisionEngineProvider = Provider<RiskDecisionEngine>((ref) {
  return RiskDecisionEngine();
});
DART

###############################################################################
# RUN 626: Device Binding Service
###############################################################################
cat > $BASE/risk/device_binding_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Statut de liaison de l'appareil
enum DeviceBindingStatus { bound, pending, revoked, unknown }

/// Informations de liaison appareil
class DeviceBinding {
  final String deviceId;
  final String userId;
  final DeviceBindingStatus status;
  final DateTime boundAt;
  final String? deviceName;
  final String? platform;
  final bool isPrimary;

  const DeviceBinding({
    required this.deviceId,
    required this.userId,
    required this.status,
    required this.boundAt,
    this.deviceName,
    this.platform,
    this.isPrimary = false,
  });

  factory DeviceBinding.fromJson(Map<String, dynamic> json) => DeviceBinding(
    deviceId: json['deviceId'] as String,
    userId: json['userId'] as String,
    status: DeviceBindingStatus.values.byName(json['status'] as String),
    boundAt: DateTime.parse(json['boundAt'] as String),
    deviceName: json['deviceName'] as String?,
    platform: json['platform'] as String?,
    isPrimary: json['isPrimary'] as bool? ?? false,
  );
}

/// Service de liaison appareil-compte.
///
/// Associe un appareil à un compte utilisateur pour
/// empêcher l'accès depuis des appareils non autorisés.
class DeviceBindingService {
  static const _tag = 'DeviceBinding';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  DeviceBindingService({required Dio dio}) : _dio = dio;

  /// Lier l'appareil actuel au compte
  Future<DeviceBinding?> bindDevice({
    required String deviceId,
    required String deviceName,
    required String platform,
  }) async {
    try {
      final response = await _dio.post('/risk/device/bind', data: {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'platform': platform,
      });
      return DeviceBinding.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Device binding failed', e);
      return null;
    }
  }

  /// Vérifier si l'appareil est lié
  Future<DeviceBindingStatus> checkBinding({required String deviceId}) async {
    try {
      final response = await _dio.get('/risk/device/binding/$deviceId');
      return DeviceBindingStatus.values.byName(
        (response.data as Map<String, dynamic>)['status'] as String);
    } catch (e) {
      _log.error('Binding check failed', e);
      return DeviceBindingStatus.unknown;
    }
  }

  /// Révoquer la liaison d'un appareil
  Future<bool> revokeBinding({required String deviceId}) async {
    try {
      await _dio.delete('/risk/device/binding/$deviceId');
      return true;
    } catch (e) {
      _log.error('Binding revocation failed', e);
      return false;
    }
  }

  /// Lister tous les appareils liés
  Future<List<DeviceBinding>> listBoundDevices() async {
    try {
      final response = await _dio.get('/risk/device/bindings');
      return (response.data as List)
          .map((e) => DeviceBinding.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.error('Failed to list bound devices', e);
      return [];
    }
  }
}

final deviceBindingProvider = Provider<DeviceBindingService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 627: SIM Change Detection Service
###############################################################################
cat > $BASE/risk/sim_change_detection_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Résultat de la détection de changement SIM
class SimChangeResult {
  final bool simChanged;
  final String? previousCarrier;
  final String? currentCarrier;
  final DateTime? lastChangeDate;
  final int changeCountLast30Days;

  const SimChangeResult({
    required this.simChanged,
    this.previousCarrier,
    this.currentCarrier,
    this.lastChangeDate,
    this.changeCountLast30Days = 0,
  });
}

/// Service de détection de changement de carte SIM.
///
/// Détecte les changements de SIM qui pourraient indiquer
/// un SIM swap (attaque par échange de SIM).
class SimChangeDetectionService {
  static const _tag = 'SimChangeDetection';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  String? _lastKnownSimId;

  SimChangeDetectionService({required Dio dio}) : _dio = dio;

  /// Vérifier si la SIM a changé
  Future<SimChangeResult> checkSimChange({
    required String currentSimId,
    required String phoneNumber,
  }) async {
    final changed = _lastKnownSimId != null && _lastKnownSimId != currentSimId;
    _lastKnownSimId = currentSimId;

    if (changed) {
      _log.warning('SIM change detected for $phoneNumber');
      // Notifier le serveur
      try {
        await _dio.post('/risk/sim-change', data: {
          'phoneNumber': phoneNumber,
          'newSimId': currentSimId,
        });
      } catch (e) {
        _log.error('Failed to report SIM change', e);
      }
    }

    return SimChangeResult(
      simChanged: changed,
      lastChangeDate: changed ? DateTime.now() : null,
    );
  }

  /// Vérifier le statut SIM swap via l'opérateur
  Future<SimChangeResult> verifyWithCarrier({
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post('/risk/sim-swap/verify', data: {
        'phoneNumber': phoneNumber,
      });
      final data = response.data as Map<String, dynamic>;
      return SimChangeResult(
        simChanged: data['recentSwap'] as bool? ?? false,
        previousCarrier: data['previousCarrier'] as String?,
        currentCarrier: data['currentCarrier'] as String?,
        lastChangeDate: data['lastChangeDate'] != null
            ? DateTime.parse(data['lastChangeDate'] as String) : null,
        changeCountLast30Days: data['changeCount30d'] as int? ?? 0,
      );
    } catch (e) {
      _log.error('Carrier SIM swap verification failed', e);
      return const SimChangeResult(simChanged: false);
    }
  }
}

final simChangeDetectionProvider = Provider<SimChangeDetectionService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 628: Unusual Activity Detection Service
###############################################################################
cat > $BASE/fraud/unusual_activity_detector.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type d'activité inhabituelle
enum UnusualActivityType {
  unusualTime,
  unusualAmount,
  unusualLocation,
  unusualRecipient,
  unusualFrequency,
  unusualDevice,
  dormantAccount,
}

/// Alerte d'activité inhabituelle
class UnusualActivityAlert {
  final String alertId;
  final UnusualActivityType type;
  final String description;
  final double severity; // 0.0 - 1.0
  final Map<String, dynamic> context;
  final DateTime detectedAt;

  const UnusualActivityAlert({
    required this.alertId,
    required this.type,
    required this.description,
    required this.severity,
    this.context = const {},
    required this.detectedAt,
  });
}

/// Service de détection d'activité inhabituelle.
///
/// Analyse le comportement de l'utilisateur pour détecter
/// les déviations par rapport à ses habitudes normales.
class UnusualActivityDetector {
  static const _tag = 'UnusualActivity';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  UnusualActivityDetector({required Dio dio}) : _dio = dio;

  /// Vérifier si une transaction est inhabituelle
  Future<List<UnusualActivityAlert>> checkTransaction({
    required String userId,
    required double amount,
    required String recipientId,
    required DateTime timestamp,
    String? location,
  }) async {
    try {
      final response = await _dio.post('/fraud/unusual-activity/check', data: {
        'userId': userId,
        'amount': amount,
        'recipientId': recipientId,
        'timestamp': timestamp.toIso8601String(),
        if (location != null) 'location': location,
      });
      final list = response.data as List;
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        return UnusualActivityAlert(
          alertId: m['alertId'] as String,
          type: UnusualActivityType.values.byName(m['type'] as String),
          description: m['description'] as String,
          severity: (m['severity'] as num).toDouble(),
          context: Map<String, dynamic>.from(m['context'] ?? {}),
          detectedAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      _log.error('Unusual activity check failed', e);
      return [];
    }
  }

  /// Vérifier l'heure habituelle de transaction
  bool isUnusualTime(DateTime timestamp) {
    final hour = timestamp.hour;
    // Transactions entre 1h et 5h du matin sont inhabituelles
    return hour >= 1 && hour <= 5;
  }
}

final unusualActivityDetectorProvider = Provider<UnusualActivityDetector>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 629: Account Takeover Prevention Service
###############################################################################
cat > $BASE/fraud/account_takeover_prevention.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Indicateur de prise de contrôle de compte
enum AtoIndicator {
  passwordChanged,
  emailChanged,
  phoneChanged,
  newDeviceLogin,
  impossibleTravel,
  simSwap,
  bulkSettingsChange,
  beneficiaryFlood,
}

/// Résultat de l'évaluation ATO
class AtoAssessment {
  final double riskScore;
  final List<AtoIndicator> indicators;
  final bool accountLocked;
  final String? recommendedAction;
  final DateTime assessedAt;

  const AtoAssessment({
    required this.riskScore,
    this.indicators = const [],
    this.accountLocked = false,
    this.recommendedAction,
    required this.assessedAt,
  });
}

/// Service de prévention de prise de contrôle de compte (ATO).
///
/// Détecte les signes de compromission de compte et prend
/// des mesures préventives automatiques.
class AccountTakeoverPreventionService {
  static const _tag = 'ATOPrevention';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  AccountTakeoverPreventionService({required Dio dio}) : _dio = dio;

  /// Évaluer le risque ATO pour la session actuelle
  Future<AtoAssessment> assessRisk({
    required String userId,
    required String deviceId,
    String? ipAddress,
    String? location,
  }) async {
    try {
      final response = await _dio.post('/fraud/ato/assess', data: {
        'userId': userId,
        'deviceId': deviceId,
        if (ipAddress != null) 'ipAddress': ipAddress,
        if (location != null) 'location': location,
      });
      final data = response.data as Map<String, dynamic>;
      return AtoAssessment(
        riskScore: (data['riskScore'] as num).toDouble(),
        indicators: (data['indicators'] as List?)
            ?.map((e) => AtoIndicator.values.byName(e as String))
            .toList() ?? [],
        accountLocked: data['accountLocked'] as bool? ?? false,
        recommendedAction: data['recommendedAction'] as String?,
        assessedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('ATO assessment failed', e);
      return AtoAssessment(riskScore: 0.0, assessedAt: DateTime.now());
    }
  }

  /// Signaler un changement sensible de compte
  Future<void> reportSensitiveChange({
    required String userId,
    required AtoIndicator changeType,
  }) async {
    try {
      await _dio.post('/fraud/ato/report-change', data: {
        'userId': userId,
        'changeType': changeType.name,
      });
    } catch (e) {
      _log.error('Failed to report sensitive change', e);
    }
  }
}

final accountTakeoverPreventionProvider = Provider<AccountTakeoverPreventionService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 630: Anomaly Detection Service
###############################################################################
cat > $BASE/fraud/anomaly_detection_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type d'anomalie détectée
enum AnomalyType {
  statisticalOutlier,
  patternDeviation,
  temporalAnomaly,
  amountAnomaly,
  frequencyAnomaly,
  networkAnomaly,
}

/// Anomalie détectée
class DetectedAnomaly {
  final String anomalyId;
  final AnomalyType type;
  final double confidence;
  final String description;
  final Map<String, dynamic> details;
  final DateTime detectedAt;

  const DetectedAnomaly({
    required this.anomalyId,
    required this.type,
    required this.confidence,
    required this.description,
    this.details = const {},
    required this.detectedAt,
  });

  factory DetectedAnomaly.fromJson(Map<String, dynamic> json) => DetectedAnomaly(
    anomalyId: json['anomalyId'] as String,
    type: AnomalyType.values.byName(json['type'] as String),
    confidence: (json['confidence'] as num).toDouble(),
    description: json['description'] as String,
    details: Map<String, dynamic>.from(json['details'] ?? {}),
    detectedAt: DateTime.parse(json['detectedAt'] as String),
  );
}

/// Service de détection d'anomalies.
///
/// Utilise des modèles statistiques côté serveur
/// pour détecter les transactions et comportements anormaux.
class AnomalyDetectionService {
  static const _tag = 'AnomalyDetection';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  AnomalyDetectionService({required Dio dio}) : _dio = dio;

  /// Analyser une transaction pour les anomalies
  Future<List<DetectedAnomaly>> analyzeTransaction({
    required String userId,
    required double amount,
    required String currency,
    required String recipientId,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      final response = await _dio.post('/fraud/anomaly/analyze', data: {
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'recipientId': recipientId,
        if (additionalContext != null) ...additionalContext,
      });
      return (response.data as List)
          .map((e) => DetectedAnomaly.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.error('Anomaly analysis failed', e);
      return [];
    }
  }

  /// Analyser le comportement utilisateur
  Future<List<DetectedAnomaly>> analyzeBehavior({
    required String userId,
    required Map<String, dynamic> behaviorData,
  }) async {
    try {
      final response = await _dio.post('/fraud/anomaly/behavior', data: {
        'userId': userId,
        'behaviorData': behaviorData,
      });
      return (response.data as List)
          .map((e) => DetectedAnomaly.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.error('Behavior anomaly analysis failed', e);
      return [];
    }
  }
}

final anomalyDetectionProvider = Provider<AnomalyDetectionService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 631: Fraud Rule Engine
###############################################################################
cat > $BASE/fraud/fraud_rule_engine.dart << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type de règle de fraude
enum FraudRuleType {
  amountThreshold,
  velocityLimit,
  deviceTrust,
  geoRestriction,
  behavioralMatch,
  blacklist,
}

class FraudRule {
  final String ruleId;
  final String name;
  final FraudRuleType type;
  final bool isActive;
  final Map<String, dynamic> conditions;
  final double weight;

  const FraudRule({
    required this.ruleId,
    required this.name,
    required this.type,
    required this.isActive,
    this.conditions = const {},
    this.weight = 1.0,
  });
}

class FraudRuleResult {
  final String ruleId;
  final bool triggered;
  final double score;
  final String? reason;

  const FraudRuleResult({
    required this.ruleId,
    required this.triggered,
    required this.score,
    this.reason,
  });
}

/// Moteur de règles de fraude côté client.
///
/// Pré-évalue les transactions localement avant
/// validation serveur.
class FraudRuleEngine {
  static const _tag = 'FraudRuleEngine';
  final AppLogger _log = AppLogger(_tag);
  final List<FraudRule> _rules;

  FraudRuleEngine({List<FraudRule> rules = const []}) : _rules = rules;

  List<FraudRuleResult> evaluate({
    required double amount,
    required String deviceId,
    required String recipientId,
    String? country,
  }) {
    return _rules.where((r) => r.isActive).map((rule) {
      switch (rule.type) {
        case FraudRuleType.amountThreshold:
          final max = (rule.conditions['maxAmount'] as num?)?.toDouble() ?? double.infinity;
          return FraudRuleResult(
            ruleId: rule.ruleId,
            triggered: amount > max,
            score: amount > max ? rule.weight : 0,
            reason: amount > max ? 'Montant dépasse ${max}' : null,
          );
        case FraudRuleType.blacklist:
          final blacklisted = List<String>.from(rule.conditions['recipientIds'] ?? []);
          final hit = blacklisted.contains(recipientId);
          return FraudRuleResult(
            ruleId: rule.ruleId,
            triggered: hit,
            score: hit ? rule.weight : 0,
            reason: hit ? 'Bénéficiaire sur liste noire' : null,
          );
        default:
          return FraudRuleResult(ruleId: rule.ruleId, triggered: false, score: 0);
      }
    }).toList();
  }
}

final fraudRuleEngineProvider = Provider<FraudRuleEngine>((ref) {
  return FraudRuleEngine();
});
DART

###############################################################################
# RUN 632: Fraud Case Model
###############################################################################
cat > $BASE/fraud/fraud_case_model.dart << 'DART'
/// Statut du dossier de fraude
enum FraudCaseStatus { open, investigating, confirmed, falsePositive, closed }

/// Type de fraude
enum FraudType {
  accountTakeover,
  identityTheft,
  transactionFraud,
  cardFraud,
  socialEngineering,
  phishing,
  simSwap,
  other,
}

/// Modèle de dossier de fraude
class FraudCase {
  final String caseId;
  final String userId;
  final FraudCaseStatus status;
  final FraudType fraudType;
  final String description;
  final double totalLoss;
  final String currency;
  final List<String> relatedTransactions;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final String? resolution;

  const FraudCase({
    required this.caseId,
    required this.userId,
    required this.status,
    required this.fraudType,
    required this.description,
    this.totalLoss = 0.0,
    required this.currency,
    this.relatedTransactions = const [],
    required this.reportedAt,
    this.resolvedAt,
    this.resolution,
  });

  factory FraudCase.fromJson(Map<String, dynamic> json) => FraudCase(
    caseId: json['caseId'] as String,
    userId: json['userId'] as String,
    status: FraudCaseStatus.values.byName(json['status'] as String),
    fraudType: FraudType.values.byName(json['fraudType'] as String),
    description: json['description'] as String,
    totalLoss: (json['totalLoss'] as num?)?.toDouble() ?? 0.0,
    currency: json['currency'] as String,
    relatedTransactions: List<String>.from(json['relatedTransactions'] ?? []),
    reportedAt: DateTime.parse(json['reportedAt'] as String),
    resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
    resolution: json['resolution'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'caseId': caseId,
    'userId': userId,
    'status': status.name,
    'fraudType': fraudType.name,
    'description': description,
    'totalLoss': totalLoss,
    'currency': currency,
    'relatedTransactions': relatedTransactions,
    'reportedAt': reportedAt.toIso8601String(),
    if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
    if (resolution != null) 'resolution': resolution,
  };
}
DART

###############################################################################
# RUN 633: Fraud Reporting Service
###############################################################################
cat > $BASE/fraud/fraud_reporting_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'fraud_case_model.dart';

/// Service de signalement de fraude.
///
/// Permet aux utilisateurs de signaler des transactions
/// frauduleuses et de suivre leurs dossiers.
class FraudReportingService {
  static const _tag = 'FraudReporting';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  FraudReportingService({required Dio dio}) : _dio = dio;

  /// Signaler une fraude
  Future<FraudCase?> reportFraud({
    required FraudType fraudType,
    required String description,
    required List<String> transactionIds,
  }) async {
    try {
      final response = await _dio.post('/fraud/report', data: {
        'fraudType': fraudType.name,
        'description': description,
        'transactionIds': transactionIds,
      });
      return FraudCase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Fraud report failed', e);
      return null;
    }
  }

  /// Obtenir les dossiers de fraude de l'utilisateur
  Future<List<FraudCase>> getMyCases() async {
    try {
      final response = await _dio.get('/fraud/cases/mine');
      return (response.data as List)
          .map((e) => FraudCase.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.error('Failed to fetch fraud cases', e);
      return [];
    }
  }

  /// Obtenir les détails d'un dossier
  Future<FraudCase?> getCaseDetails(String caseId) async {
    try {
      final response = await _dio.get('/fraud/cases/$caseId');
      return FraudCase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Failed to fetch case details', e);
      return null;
    }
  }
}

final fraudReportingProvider = Provider<FraudReportingService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 634: Fraud Index
###############################################################################
cat > $BASE/fraud/index.dart << 'DART'
export 'unusual_activity_detector.dart';
export 'account_takeover_prevention.dart';
export 'anomaly_detection_service.dart';
export 'fraud_rule_engine.dart';
export 'fraud_case_model.dart';
export 'fraud_reporting_service.dart';
DART

###############################################################################
# RUN 635: Security Audit Log Service
###############################################################################
cat > $BASE/audit/security_audit_log.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Catégorie d'événement d'audit de sécurité
enum SecurityAuditCategory {
  authentication,
  authorization,
  dataAccess,
  configChange,
  securityThreat,
  compliance,
}

/// Entrée du journal d'audit de sécurité
class SecurityAuditEntry {
  final String entryId;
  final SecurityAuditCategory category;
  final String action;
  final String description;
  final String? userId;
  final String? deviceId;
  final String? ipAddress;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const SecurityAuditEntry({
    required this.entryId,
    required this.category,
    required this.action,
    required this.description,
    this.userId,
    this.deviceId,
    this.ipAddress,
    this.metadata = const {},
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'entryId': entryId,
    'category': category.name,
    'action': action,
    'description': description,
    if (userId != null) 'userId': userId,
    if (deviceId != null) 'deviceId': deviceId,
    if (ipAddress != null) 'ipAddress': ipAddress,
    'metadata': metadata,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Service de journal d'audit de sécurité.
///
/// Enregistre tous les événements de sécurité pour
/// la conformité et l'investigation.
class SecurityAuditLogService {
  static const _tag = 'SecurityAuditLog';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  final List<SecurityAuditEntry> _pendingEntries = [];
  static const int _batchSize = 20;

  SecurityAuditLogService({required Dio dio}) : _dio = dio;

  /// Enregistrer un événement d'audit
  Future<void> logEvent({
    required SecurityAuditCategory category,
    required String action,
    required String description,
    String? userId,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) async {
    final entry = SecurityAuditEntry(
      entryId: '${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      action: action,
      description: description,
      userId: userId,
      deviceId: deviceId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
    );
    _pendingEntries.add(entry);
    if (_pendingEntries.length >= _batchSize) {
      await flush();
    }
  }

  /// Envoyer les entrées en attente
  Future<void> flush() async {
    if (_pendingEntries.isEmpty) return;
    final batch = List<SecurityAuditEntry>.from(_pendingEntries);
    _pendingEntries.clear();
    try {
      await _dio.post('/audit/security/batch', data: {
        'entries': batch.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      _log.error('Failed to flush audit log', e);
      _pendingEntries.insertAll(0, batch); // Remettre en file
    }
  }
}

final securityAuditLogProvider = Provider<SecurityAuditLogService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 636: User Action Audit Trail
###############################################################################
cat > $BASE/audit/user_action_audit_trail.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type d'action utilisateur
enum UserActionType {
  login,
  logout,
  transfer,
  deposit,
  withdrawal,
  profileUpdate,
  settingsChange,
  beneficiaryAdd,
  beneficiaryRemove,
  pinChange,
  biometricEnroll,
  kycSubmit,
  supportRequest,
  screenView,
}

/// Entrée de piste d'audit utilisateur
class UserActionEntry {
  final String actionId;
  final UserActionType actionType;
  final String description;
  final String? targetId;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  const UserActionEntry({
    required this.actionId,
    required this.actionType,
    required this.description,
    this.targetId,
    this.details = const {},
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'actionId': actionId,
    'actionType': actionType.name,
    'description': description,
    if (targetId != null) 'targetId': targetId,
    'details': details,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Piste d'audit des actions utilisateur.
///
/// Enregistre toutes les actions significatives
/// de l'utilisateur pour la traçabilité.
class UserActionAuditTrail {
  static const _tag = 'UserAuditTrail';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  final List<UserActionEntry> _buffer = [];

  UserActionAuditTrail({required Dio dio}) : _dio = dio;

  void record({
    required UserActionType actionType,
    required String description,
    String? targetId,
    Map<String, dynamic>? details,
  }) {
    _buffer.add(UserActionEntry(
      actionId: '${DateTime.now().millisecondsSinceEpoch}',
      actionType: actionType,
      description: description,
      targetId: targetId,
      details: details ?? {},
      timestamp: DateTime.now(),
    ));
  }

  Future<void> flush() async {
    if (_buffer.isEmpty) return;
    final batch = List<UserActionEntry>.from(_buffer);
    _buffer.clear();
    try {
      await _dio.post('/audit/user-actions/batch', data: {
        'actions': batch.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      _log.error('Failed to flush user action audit', e);
      _buffer.insertAll(0, batch);
    }
  }
}

final userActionAuditTrailProvider = Provider<UserActionAuditTrail>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 637: Login Attempt Tracking Service
###############################################################################
cat > $BASE/audit/login_attempt_tracker.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Résultat de tentative de connexion
enum LoginAttemptResult { success, failure, locked, mfaRequired, mfaFailed }

/// Entrée de tentative de connexion
class LoginAttempt {
  final String attemptId;
  final LoginAttemptResult result;
  final String? method; // pin, biometric, password
  final String? deviceId;
  final String? ipAddress;
  final String? failureReason;
  final DateTime timestamp;

  const LoginAttempt({
    required this.attemptId,
    required this.result,
    this.method,
    this.deviceId,
    this.ipAddress,
    this.failureReason,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'attemptId': attemptId,
    'result': result.name,
    if (method != null) 'method': method,
    if (deviceId != null) 'deviceId': deviceId,
    if (ipAddress != null) 'ipAddress': ipAddress,
    if (failureReason != null) 'failureReason': failureReason,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Service de suivi des tentatives de connexion.
///
/// Enregistre et analyse les tentatives de connexion
/// pour détecter les attaques par force brute.
class LoginAttemptTracker {
  static const _tag = 'LoginAttemptTracker';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  final List<LoginAttempt> _recentAttempts = [];

  LoginAttemptTracker({required Dio dio}) : _dio = dio;

  /// Enregistrer une tentative de connexion
  Future<void> recordAttempt({
    required LoginAttemptResult result,
    String? method,
    String? deviceId,
    String? failureReason,
  }) async {
    final attempt = LoginAttempt(
      attemptId: '${DateTime.now().millisecondsSinceEpoch}',
      result: result,
      method: method,
      deviceId: deviceId,
      failureReason: failureReason,
      timestamp: DateTime.now(),
    );
    _recentAttempts.add(attempt);

    try {
      await _dio.post('/audit/login-attempts', data: attempt.toJson());
    } catch (e) {
      _log.error('Failed to record login attempt', e);
    }
  }

  /// Nombre d'échecs consécutifs récents
  int get consecutiveFailures {
    int count = 0;
    for (final a in _recentAttempts.reversed) {
      if (a.result == LoginAttemptResult.failure) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Vérifier si le compte devrait être verrouillé
  bool shouldLockAccount({int maxAttempts = 5}) {
    return consecutiveFailures >= maxAttempts;
  }

  /// Obtenir l'historique des connexions
  Future<List<LoginAttempt>> getHistory({int limit = 20}) async {
    try {
      final response = await _dio.get('/audit/login-attempts',
          queryParameters: {'limit': limit});
      return (response.data as List).map((e) {
        final m = e as Map<String, dynamic>;
        return LoginAttempt(
          attemptId: m['attemptId'] as String,
          result: LoginAttemptResult.values.byName(m['result'] as String),
          method: m['method'] as String?,
          deviceId: m['deviceId'] as String?,
          failureReason: m['failureReason'] as String?,
          timestamp: DateTime.parse(m['timestamp'] as String),
        );
      }).toList();
    } catch (e) {
      _log.error('Failed to fetch login history', e);
      return [];
    }
  }
}

final loginAttemptTrackerProvider = Provider<LoginAttemptTracker>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 638: Compliance Event Logger
###############################################################################
cat > $BASE/audit/compliance_event_logger.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type d'événement de conformité
enum ComplianceEventType {
  kycCompleted,
  kycExpired,
  amlAlert,
  sanctionsHit,
  pepIdentified,
  ctrFiled,
  sarFiled,
  limitBreached,
  regulatoryChange,
  auditRequest,
  dataAccessRequest,
  consentChange,
}

/// Événement de conformité
class ComplianceEvent {
  final String eventId;
  final ComplianceEventType type;
  final String description;
  final String? userId;
  final String? transactionId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const ComplianceEvent({
    required this.eventId,
    required this.type,
    required this.description,
    this.userId,
    this.transactionId,
    this.data = const {},
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'type': type.name,
    'description': description,
    if (userId != null) 'userId': userId,
    if (transactionId != null) 'transactionId': transactionId,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Journal des événements de conformité.
///
/// Enregistre tous les événements liés à la conformité
/// réglementaire pour le reporting BCEAO et CENTIF.
class ComplianceEventLogger {
  static const _tag = 'ComplianceEventLogger';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  final List<ComplianceEvent> _buffer = [];

  ComplianceEventLogger({required Dio dio}) : _dio = dio;

  void log({
    required ComplianceEventType type,
    required String description,
    String? userId,
    String? transactionId,
    Map<String, dynamic>? data,
  }) {
    _buffer.add(ComplianceEvent(
      eventId: '${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      description: description,
      userId: userId,
      transactionId: transactionId,
      data: data ?? {},
      timestamp: DateTime.now(),
    ));
  }

  Future<void> flush() async {
    if (_buffer.isEmpty) return;
    final batch = List<ComplianceEvent>.from(_buffer);
    _buffer.clear();
    try {
      await _dio.post('/audit/compliance-events/batch', data: {
        'events': batch.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      _log.error('Failed to flush compliance events', e);
      _buffer.insertAll(0, batch);
    }
  }
}

final complianceEventLoggerProvider = Provider<ComplianceEventLogger>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 639: Audit Index
###############################################################################
cat > $BASE/audit/index.dart << 'DART'
export 'security_audit_log.dart';
export 'user_action_audit_trail.dart';
export 'login_attempt_tracker.dart';
export 'compliance_event_logger.dart';
DART

echo "Batch 2 (runs 620-639) complete"
