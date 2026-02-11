import 'package:flutter/material.dart';

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
  switch (status.toLowerCase()) {
    case 'approved':
      return const KycStatusConfig(
        label: 'Verified',
        color: Color(0xFF16A34A),
        icon: Icons.verified_rounded,
        description: 'Your identity has been verified. Full access enabled.',
      );
    case 'submitted':
    case 'manual_review':
      return const KycStatusConfig(
        label: 'Under Review',
        color: Color(0xFFF59E0B),
        icon: Icons.hourglass_top_rounded,
        description: 'Your documents are being reviewed. This usually takes 24-48 hours.',
      );
    case 'rejected':
      return const KycStatusConfig(
        label: 'Rejected',
        color: Color(0xFFDC2626),
        icon: Icons.cancel_rounded,
        description: 'Your verification was rejected. Please resubmit with valid documents.',
      );
    case 'pending':
    default:
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
  switch (status.toLowerCase()) {
    case 'approved':
      return 'Daily: 5,000 USDC · Monthly: 50,000 USDC';
    case 'submitted':
    case 'manual_review':
      return 'Daily: 500 USDC · Monthly: 5,000 USDC';
    default:
      return 'Daily: 50 USDC · Monthly: 200 USDC · Verify to increase';
  }
}
