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
