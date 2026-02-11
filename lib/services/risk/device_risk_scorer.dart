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
