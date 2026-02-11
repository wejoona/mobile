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
