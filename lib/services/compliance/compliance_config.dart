import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration des règles de conformité.
class ComplianceConfig {
  final double dailyLimitBasicXof;
  final double dailyLimitVerifiedXof;
  final double monthlyLimitBasicXof;
  final double monthlyLimitVerifiedXof;
  final double sarThresholdXof; // Suspicious Activity Report threshold
  final int kycRenewalDays;
  final bool enableCrossBorderChecks;
  final bool enablePepScreening;

  const ComplianceConfig({
    this.dailyLimitBasicXof = 200000,
    this.dailyLimitVerifiedXof = 2000000,
    this.monthlyLimitBasicXof = 1000000,
    this.monthlyLimitVerifiedXof = 10000000,
    this.sarThresholdXof = 5000000,
    this.kycRenewalDays = 365,
    this.enableCrossBorderChecks = true,
    this.enablePepScreening = true,
  });
}

final complianceConfigProvider = Provider<ComplianceConfig>((ref) {
  return const ComplianceConfig();
});
