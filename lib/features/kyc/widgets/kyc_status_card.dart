import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/kyc_profile.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// KYC status overview card.
class KycStatusCard extends StatelessWidget {
  const KycStatusCard({super.key, required this.profile, this.onUpgrade});

  final KycProfile profile;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statusIcon(context),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.settings_kycVerification,
                      variant: AppTextVariant.titleSmall,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      _statusText(l10n),
                      variant: AppTextVariant.bodySmall,
                      color: _statusColor(context),
                    ),
                  ],
                ),
              ),
              _levelBadge(context),
            ],
          ),
          if (profile.needsUpgrade) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppText(
                    l10n.kyc_completeVerification(
                      profile.dailyLimit.toString(),
                    ),
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton(
                  label: l10n.kyc_verify,
                  onPressed: onUpgrade,
                  size: AppButtonSize.small,
                ),
              ],
            ),
          ],
          if (profile.isRejected && profile.rejectionReason != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.errorBg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.error.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: colors.errorText),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText(
                      profile.rejectionReason!,
                      variant: AppTextVariant.bodySmall,
                      color: colors.errorText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _levelBadge(BuildContext context) {
    return StatusPill(
      label: profile.level.name.toUpperCase(),
      tone: profile.isVerified ? StatusTone.success : StatusTone.brand,
      icon: profile.isVerified
          ? Icons.verified_user_rounded
          : Icons.shield_outlined,
      compact: true,
      emphasis: true,
    );
  }

  Color _statusColor(BuildContext context) {
    if (profile.isVerified) return context.colors.success;
    if (profile.isPending) return context.colors.warning;
    if (profile.isRejected) return context.colors.error;
    return context.colors.textSecondary;
  }

  String _statusText(AppLocalizations l10n) {
    if (profile.isVerified) return l10n.kyc_verified;
    if (profile.isPending) return l10n.kyc_pending;
    if (profile.isRejected) return l10n.kyc_rejected;
    return l10n.kyc_notStarted;
  }
}
