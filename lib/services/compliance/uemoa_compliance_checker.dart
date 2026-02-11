import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// UEMOA regulatory compliance result.
class ComplianceCheckResult {
  final bool isCompliant;
  final List<String> violations;
  final List<String> warnings;
  final Map<String, double> limits;

  const ComplianceCheckResult({
    required this.isCompliant,
    this.violations = const [],
    this.warnings = const [],
    this.limits = const {},
  });
}

/// Checks transactions against UEMOA (Union Economique et Monetaire
/// Ouest Africaine) regulatory requirements.
///
/// Enforces transaction limits, KYC tier restrictions, and cross-border
/// reporting thresholds per BCEAO instructions.
class UemoaComplianceChecker {
  static const _tag = 'UemoaCompliance';
  final AppLogger _log = AppLogger(_tag);

  // BCEAO-defined limits in XOF
  static const double _dailyLimitTier1 = 200000;    // ~305 EUR
  static const double _dailyLimitTier2 = 2000000;   // ~3050 EUR
  static const double _dailyLimitTier3 = 10000000;  // ~15250 EUR
  static const double _monthlyLimitTier1 = 1000000;
  static const double _monthlyLimitTier2 = 10000000;
  static const double _monthlyLimitTier3 = 50000000;
  static const double _singleTxReportThreshold = 5000000; // ~7625 EUR
  static const double _crossBorderReportThreshold = 1000000;

  /// Check if a transaction is compliant.
  ComplianceCheckResult checkTransaction({
    required double amountCfa,
    required int kycTier,
    required double dailyTotalCfa,
    required double monthlyTotalCfa,
    required bool isCrossBorder,
  }) {
    final violations = <String>[];
    final warnings = <String>[];

    final dailyLimit = _dailyLimitForTier(kycTier);
    final monthlyLimit = _monthlyLimitForTier(kycTier);

    if (dailyTotalCfa + amountCfa > dailyLimit) {
      violations.add(
          'Limite journaliere depassee: ${dailyLimit.toStringAsFixed(0)} XOF');
    }

    if (monthlyTotalCfa + amountCfa > monthlyLimit) {
      violations.add(
          'Limite mensuelle depassee: ${monthlyLimit.toStringAsFixed(0)} XOF');
    }

    if (amountCfa >= _singleTxReportThreshold) {
      warnings.add('Transaction soumise a declaration BCEAO');
    }

    if (isCrossBorder && amountCfa >= _crossBorderReportThreshold) {
      warnings.add('Transfert transfrontalier soumis a declaration');
    }

    if (violations.isNotEmpty) {
      _log.debug('Compliance violations: ${violations.join(', ')}');
    }

    return ComplianceCheckResult(
      isCompliant: violations.isEmpty,
      violations: violations,
      warnings: warnings,
      limits: {
        'dailyLimit': dailyLimit,
        'monthlyLimit': monthlyLimit,
        'dailyUsed': dailyTotalCfa,
        'monthlyUsed': monthlyTotalCfa,
      },
    );
  }

  double _dailyLimitForTier(int tier) {
    switch (tier) {
      case 1: return _dailyLimitTier1;
      case 2: return _dailyLimitTier2;
      case 3: return _dailyLimitTier3;
      default: return _dailyLimitTier1;
    }
  }

  double _monthlyLimitForTier(int tier) {
    switch (tier) {
      case 1: return _monthlyLimitTier1;
      case 2: return _monthlyLimitTier2;
      case 3: return _monthlyLimitTier3;
      default: return _monthlyLimitTier1;
    }
  }
}

final uemoaComplianceCheckerProvider =
    Provider<UemoaComplianceChecker>((ref) {
  return UemoaComplianceChecker();
});
