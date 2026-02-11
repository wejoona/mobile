import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Indicateurs de compte mule
class MuleAccountIndicators {
  final double riskScore;
  final bool isSuspected;
  final List<String> indicators;
  final DateTime assessedAt;

  const MuleAccountIndicators({
    required this.riskScore,
    required this.isSuspected,
    this.indicators = const [],
    required this.assessedAt,
  });
}

/// Détecteur de comptes mule.
///
/// Identifie les comptes utilisés comme intermédiaires
/// pour le blanchiment d'argent (money mules).
class MuleAccountDetector {
  static const _tag = 'MuleDetector';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  MuleAccountDetector({required Dio dio}) : _dio = dio;

  Future<MuleAccountIndicators> assess({required String userId}) async {
    try {
      final response = await _dio.get('/fraud/mule-detection/$userId');
      final data = response.data as Map<String, dynamic>;
      return MuleAccountIndicators(
        riskScore: (data['riskScore'] as num).toDouble(),
        isSuspected: data['isSuspected'] as bool? ?? false,
        indicators: List<String>.from(data['indicators'] ?? []),
        assessedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Mule account assessment failed', e);
      return MuleAccountIndicators(
        riskScore: 0.0, isSuspected: false, assessedAt: DateTime.now(),
      );
    }
  }
}

final muleAccountDetectorProvider = Provider<MuleAccountDetector>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
