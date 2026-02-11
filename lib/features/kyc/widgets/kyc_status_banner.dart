import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';

/// Banner showing the user current KYC verification status.
class KycStatusBanner extends StatelessWidget {
  const KycStatusBanner({
    super.key,
    required this.status,
    this.onTap,
  });

  final KycStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (status == KycStatus.verified) return const SizedBox.shrink();

    final (icon, title, subtitle, color) = _config;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }

  (IconData, String, String, Color) get _config {
    switch (status) {
      case KycStatus.none:
      case KycStatus.pending:
        return (
          Icons.verified_user_outlined,
          'Verify your identity',
          'Complete KYC to unlock higher limits',
          Colors.orange,
        );
      case KycStatus.submitted:
      case KycStatus.documentsPending:
        return (
          Icons.hourglass_top,
          'Verification in progress',
          'We are reviewing your documents',
          Colors.blue,
        );
      case KycStatus.rejected:
        return (
          Icons.error_outline,
          'Verification failed',
          'Please resubmit your documents',
          Colors.red,
        );
      case KycStatus.verified:
        return (
          Icons.check_circle_outline,
          'Verified',
          'Your identity is verified',
          Colors.green,
        );
      default:
        return (
          Icons.info_outline,
          'Verification needed',
          'Complete verification to continue',
          Colors.orange,
        );
    }
  }
}
