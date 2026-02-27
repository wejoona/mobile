import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/kyc_profile.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// KYC status overview card.
class KycStatusCard extends StatelessWidget {
  final KycProfile profile;
  final VoidCallback? onUpgrade;

  const KycStatusCard({super.key, required this.profile, this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.lg)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statusIcon(context),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KYC Verification', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      Text(_statusText, style: theme.textTheme.bodySmall?.copyWith(color: _statusColor(context))),
                    ],
                  ),
                ),
                _levelBadge(context),
              ],
            ),
            if (profile.needsUpgrade) ...[
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: Text(AppLocalizations.of(context)!.kyc_completeVerification(profile.dailyLimit.toString()), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                  SizedBox(width: AppSpacing.md),
                  AppButton(
                    label: AppLocalizations.of(context)!.kyc_verify,
                    onPressed: onUpgrade,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
            if (profile.isRejected && profile.rejectionReason != null) ...[
              SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(AppSpacing.sm)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(profile.rejectionReason!, style: TextStyle(fontSize: 12, color: Colors.red.shade700))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(BuildContext context) {
    final color = _statusColor(context);
    IconData icon;
    if (profile.isVerified) {
      icon = Icons.verified_rounded;
    } else if (profile.isPending) {
      icon = Icons.hourglass_top_rounded;
    } else if (profile.isRejected) {
      icon = Icons.cancel_rounded;
    } else {
      icon = Icons.person_outline_rounded;
    }
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _levelBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
      child: Text(profile.level.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }

  Color _statusColor(BuildContext context) {
    if (profile.isVerified) return context.colors.success;
    if (profile.isPending) return context.colors.warning;
    if (profile.isRejected) return context.colors.error;
    return context.colors.textSecondary;
  }

  String get _statusText {
    if (profile.isVerified) return 'Verified';
    if (profile.isPending) return 'Pending review';
    if (profile.isRejected) return 'Rejected';
    return 'Not verified';
  }
}
