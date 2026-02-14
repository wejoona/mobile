import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Évaluation du risque pour les transactions et les utilisateurs.
class RiskAssessmentService {
  static const _tag = 'RiskAssess';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);

  /// Assess risk for a transaction.
  RiskAssessment assessTransaction({
    required double amount,
    required String destinationCountry,
    required String userKycTier,
    required int userAccountAgeDays,
  }) {
    double score = 0;

    if (amount > 500000) score += 20;
    if (amount > 2000000) score += 30;
    if (destinationCountry != 'CI') score += 15;
    if (userKycTier == 'basic') score += 10;
    if (userAccountAgeDays < 30) score += 15;

    final level = score >= 60 ? 'high' : (score >= 30 ? 'medium' : 'low');
    return RiskAssessment(score: score, level: level);
  }

  /// Assess user risk profile.
  RiskAssessment assessUser({
    required int transactionCount,
    required double totalVolume,
    required int accountAgeDays,
  }) {
    double score = 0;
    if (totalVolume > 5000000) score += 25;
    if (transactionCount > 100 && accountAgeDays < 30) score += 30;

    final level = score >= 50 ? 'high' : (score >= 25 ? 'medium' : 'low');
    return RiskAssessment(score: score, level: level);
  }
}

class RiskAssessment {
  final double score;
  final String level;
  const RiskAssessment({required this.score, required this.level});
}

final riskAssessmentServiceProvider = Provider<RiskAssessmentService>((ref) {
  return RiskAssessmentService();
});
