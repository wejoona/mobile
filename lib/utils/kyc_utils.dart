import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_status.dart';

/// KYC status display configuration
class KycStatusConfig {
  final String label;
  final Color color;
  final IconData icon;
  final String description;

  const KycStatusConfig({
    required this.label,
    required this.color,
    required this.icon,
    required this.description,
  });
}

/// Get display configuration for a KYC status
KycStatusConfig kycStatusConfig(String status) {
  switch (_normalizeKycStatus(status)) {
    case KycStatus.verified:
      return const KycStatusConfig(
        label: 'Verified',
        color: Color(0xFF16A34A),
        icon: Icons.verified_rounded,
        description: 'Your identity has been verified. Full access enabled.',
      );
    case KycStatus.submitted:
    case KycStatus.manualReview:
      return const KycStatusConfig(
        label: 'Under Review',
        color: Color(0xFFF59E0B),
        icon: Icons.hourglass_top_rounded,
        description:
            'Your documents are being reviewed. This usually takes 24-48 hours.',
      );
    case KycStatus.rejected:
      return const KycStatusConfig(
        label: 'Rejected',
        color: Color(0xFFDC2626),
        icon: Icons.cancel_rounded,
        description:
            'Your verification was rejected. Please resubmit with valid documents.',
      );
    case KycStatus.none:
    case KycStatus.pending:
    case KycStatus.documentsPending:
    case KycStatus.additionalInfoNeeded:
      return const KycStatusConfig(
        label: 'Not Verified',
        color: Color(0xFF6B7280),
        icon: Icons.shield_outlined,
        description: 'Complete identity verification to unlock full features.',
      );
  }
}

/// Get transaction limits description for KYC status
String kycLimitDescription(String status) {
  switch (_normalizeKycStatus(status)) {
    case KycStatus.verified:
      return 'Daily: 5,000 USDC · Monthly: 50,000 USDC';
    case KycStatus.submitted:
    case KycStatus.manualReview:
      return 'Daily: 500 USDC · Monthly: 5,000 USDC';
    case KycStatus.none:
    case KycStatus.pending:
    case KycStatus.documentsPending:
    case KycStatus.rejected:
    case KycStatus.additionalInfoNeeded:
      return 'Daily: 50 USDC · Monthly: 200 USDC · Verify to increase';
  }
}

KycStatus _normalizeKycStatus(String status) {
  final normalized = status.toLowerCase();
  if (normalized == 'not_started') {
    return KycStatus.none;
  }
  return KycStatus.fromString(normalized);
}
