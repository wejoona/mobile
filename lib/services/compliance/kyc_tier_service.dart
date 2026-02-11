import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// KYC verification tier per BCEAO classification.
enum KycTier {
  /// Tier 0: Unverified - very limited functionality
  unverified,
  /// Tier 1: Phone verified - basic transfers
  basic,
  /// Tier 2: ID verified - standard limits
  standard,
  /// Tier 3: Full KYC - highest limits
  full,
}

/// KYC tier details with associated limits.
class KycTierInfo {
  final KycTier tier;
  final double dailyLimitCfa;
  final double monthlyLimitCfa;
  final double singleTxLimitCfa;
  final bool crossBorderAllowed;
  final List<String> requiredDocuments;

  const KycTierInfo({
    required this.tier,
    required this.dailyLimitCfa,
    required this.monthlyLimitCfa,
    required this.singleTxLimitCfa,
    required this.crossBorderAllowed,
    this.requiredDocuments = const [],
  });
}

/// Manages KYC tier status and upgrade requirements.
class KycTierService {
  static const _tag = 'KycTier';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  static const _tierInfoMap = {
    KycTier.unverified: KycTierInfo(
      tier: KycTier.unverified,
      dailyLimitCfa: 0,
      monthlyLimitCfa: 0,
      singleTxLimitCfa: 0,
      crossBorderAllowed: false,
    ),
    KycTier.basic: KycTierInfo(
      tier: KycTier.basic,
      dailyLimitCfa: 200000,
      monthlyLimitCfa: 1000000,
      singleTxLimitCfa: 100000,
      crossBorderAllowed: false,
      requiredDocuments: ['Numero de telephone verifie'],
    ),
    KycTier.standard: KycTierInfo(
      tier: KycTier.standard,
      dailyLimitCfa: 2000000,
      monthlyLimitCfa: 10000000,
      singleTxLimitCfa: 1000000,
      crossBorderAllowed: true,
      requiredDocuments: ['Piece d\'identite', 'Photo selfie'],
    ),
    KycTier.full: KycTierInfo(
      tier: KycTier.full,
      dailyLimitCfa: 10000000,
      monthlyLimitCfa: 50000000,
      singleTxLimitCfa: 5000000,
      crossBorderAllowed: true,
      requiredDocuments: [
        'Piece d\'identite',
        'Justificatif de domicile',
        'Photo selfie',
        'Justificatif de revenus',
      ],
    ),
  };

  KycTierService({required Dio dio}) : _dio = dio;

  /// Get tier info for a given tier.
  KycTierInfo getTierInfo(KycTier tier) {
    return _tierInfoMap[tier]!;
  }

  /// Get requirements for upgrading to the next tier.
  List<String> upgradeRequirements(KycTier currentTier) {
    final nextTier = KycTier.values.indexOf(currentTier) + 1;
    if (nextTier >= KycTier.values.length) return [];
    return getTierInfo(KycTier.values[nextTier]).requiredDocuments;
  }
}

final kycTierServiceProvider = Provider<KycTierService>((ref) {
  return KycTierService(dio: Dio());
});
