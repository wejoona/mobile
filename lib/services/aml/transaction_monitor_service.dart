import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Niveau de risque AML pour une transaction
enum AmlRiskLevel { low, medium, high, critical }

/// Résultat du monitoring AML
class AmlMonitoringResult {
  final String transactionId;
  final AmlRiskLevel riskLevel;
  final double score;
  final List<String> triggeredRules;
  final bool requiresReview;
  final DateTime evaluatedAt;

  const AmlMonitoringResult({
    required this.transactionId,
    required this.riskLevel,
    required this.score,
    this.triggeredRules = const [],
    required this.requiresReview,
    required this.evaluatedAt,
  });

  Map<String, dynamic> toJson() => {
    'transactionId': transactionId,
    'riskLevel': riskLevel.name,
    'score': score,
    'triggeredRules': triggeredRules,
    'requiresReview': requiresReview,
    'evaluatedAt': evaluatedAt.toIso8601String(),
  };
}

/// Service de surveillance des transactions AML.
///
/// Surveille les transactions en temps réel pour détecter
/// les activités suspectes de blanchiment d'argent.
class TransactionMonitorService {
  static const _tag = 'AmlTransactionMonitor';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  TransactionMonitorService({required Dio dio}) : _dio = dio;

  /// Évaluer une transaction avant exécution
  Future<AmlMonitoringResult> evaluateTransaction({
    required String transactionId,
    required double amount,
    required String currency,
    required String senderWallet,
    required String recipientWallet,
    String? recipientCountry,
  }) async {
    try {
      final response = await _dio.post('/aml/monitor/evaluate', data: {
        'transactionId': transactionId,
        'amount': amount,
        'currency': currency,
        'senderWallet': senderWallet,
        'recipientWallet': recipientWallet,
        if (recipientCountry != null) 'recipientCountry': recipientCountry,
      });
      final data = response.data as Map<String, dynamic>;
      return AmlMonitoringResult(
        transactionId: transactionId,
        riskLevel: AmlRiskLevel.values.byName(data['riskLevel'] ?? 'low'),
        score: (data['score'] as num?)?.toDouble() ?? 0.0,
        triggeredRules: List<String>.from(data['triggeredRules'] ?? []),
        requiresReview: data['requiresReview'] as bool? ?? false,
        evaluatedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Transaction monitoring failed', e);
      return AmlMonitoringResult(
        transactionId: transactionId,
        riskLevel: AmlRiskLevel.medium,
        score: 0.5,
        requiresReview: true,
        evaluatedAt: DateTime.now(),
      );
    }
  }

  /// Signaler une transaction suspecte
  Future<bool> reportSuspiciousTransaction({
    required String transactionId,
    required String reason,
  }) async {
    try {
      await _dio.post('/aml/monitor/report', data: {
        'transactionId': transactionId,
        'reason': reason,
      });
      return true;
    } catch (e) {
      _log.error('Failed to report suspicious transaction', e);
      return false;
    }
  }
}

/// Provider pour le service de monitoring AML
final transactionMonitorProvider = Provider<TransactionMonitorService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
