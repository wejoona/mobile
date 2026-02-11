import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Facteurs de risque pour une transaction
class TransactionRiskFactors {
  final double amount;
  final String currency;
  final String? recipientCountry;
  final bool isFirstTransaction;
  final bool isNewRecipient;
  final bool isCrossBorder;
  final int dailyTransactionCount;
  final double dailyTotal;
  final String? deviceRiskLevel;

  const TransactionRiskFactors({
    required this.amount,
    required this.currency,
    this.recipientCountry,
    this.isFirstTransaction = false,
    this.isNewRecipient = false,
    this.isCrossBorder = false,
    this.dailyTransactionCount = 0,
    this.dailyTotal = 0.0,
    this.deviceRiskLevel,
  });
}

/// Score de risque d'une transaction
class TransactionRiskScore {
  final double score; // 0.0 - 1.0
  final String level; // low, medium, high, critical
  final List<String> factors;
  final bool requiresAdditionalAuth;
  final bool requiresManualReview;
  final DateTime scoredAt;

  const TransactionRiskScore({
    required this.score,
    required this.level,
    this.factors = const [],
    this.requiresAdditionalAuth = false,
    this.requiresManualReview = false,
    required this.scoredAt,
  });
}

/// Service de scoring de risque des transactions.
///
/// Évalue le niveau de risque de chaque transaction
/// en combinant facteurs locaux et analyse serveur.
class TransactionRiskScorer {
  static const _tag = 'TransactionRiskScorer';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  TransactionRiskScorer({required Dio dio}) : _dio = dio;

  /// Calculer le score de risque
  Future<TransactionRiskScore> scoreTransaction(TransactionRiskFactors factors) async {
    // Pré-évaluation locale
    final localScore = _calculateLocalScore(factors);

    try {
      final response = await _dio.post('/risk/transaction/score', data: {
        'amount': factors.amount,
        'currency': factors.currency,
        'recipientCountry': factors.recipientCountry,
        'isFirstTransaction': factors.isFirstTransaction,
        'isNewRecipient': factors.isNewRecipient,
        'isCrossBorder': factors.isCrossBorder,
        'dailyTransactionCount': factors.dailyTransactionCount,
        'dailyTotal': factors.dailyTotal,
        'localScore': localScore,
      });
      final data = response.data as Map<String, dynamic>;
      return TransactionRiskScore(
        score: (data['score'] as num).toDouble(),
        level: data['level'] as String,
        factors: List<String>.from(data['factors'] ?? []),
        requiresAdditionalAuth: data['requiresAdditionalAuth'] as bool? ?? false,
        requiresManualReview: data['requiresManualReview'] as bool? ?? false,
        scoredAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Server risk scoring failed, using local score', e);
      return TransactionRiskScore(
        score: localScore,
        level: _scoreToLevel(localScore),
        factors: _getLocalFactors(factors),
        requiresAdditionalAuth: localScore > 0.7,
        requiresManualReview: localScore > 0.85,
        scoredAt: DateTime.now(),
      );
    }
  }

  double _calculateLocalScore(TransactionRiskFactors f) {
    double score = 0.0;
    if (f.amount > 1000000) score += 0.2;
    if (f.amount > 5000000) score += 0.2;
    if (f.isFirstTransaction) score += 0.1;
    if (f.isNewRecipient) score += 0.1;
    if (f.isCrossBorder) score += 0.15;
    if (f.dailyTransactionCount > 10) score += 0.15;
    return score.clamp(0.0, 1.0);
  }

  String _scoreToLevel(double score) {
    if (score < 0.3) return 'low';
    if (score < 0.6) return 'medium';
    if (score < 0.85) return 'high';
    return 'critical';
  }

  List<String> _getLocalFactors(TransactionRiskFactors f) {
    final factors = <String>[];
    if (f.amount > 1000000) factors.add('Montant élevé');
    if (f.isNewRecipient) factors.add('Nouveau bénéficiaire');
    if (f.isCrossBorder) factors.add('Transaction transfrontalière');
    return factors;
  }
}

final transactionRiskScorerProvider = Provider<TransactionRiskScorer>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
