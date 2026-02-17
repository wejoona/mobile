import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/kyc_profile.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// KYC status overview card.
class KycStatusCard extends StatelessWidget {
  final KycProfile profile;
  final VoidCallback? onUpgrade;

  const KycStatusCard({super.key, required this.profile, this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statusIcon(context),
                const SizedBox(width: 12),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text(AppLocalizations.of(context)!.kyc_completeVerification(profile.dailyLimit.toString()), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: onUpgrade, style: FilledButton.styleFrom(visualDensity: VisualDensity.compact), child: Text(AppLocalizations.of(context)!.kyc_verify)),
                ],
              ),
            ],
            if (profile.isRejected && profile.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _levelBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
      child: Text(profile.level.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }

  Color _statusColor(BuildContext context) {
    if (profile.isVerified) return Colors.green;
    if (profile.isPending) return Colors.orange;
    if (profile.isRejected) return Colors.red;
    return Colors.grey;
  }

  String get _statusText {
    if (profile.isVerified) return 'Verified';
    if (profile.isPending) return 'Pending review';
    if (profile.isRejected) return 'Rejected';
    return 'Not verified';
  }
}
