import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Banner showing the user current KYC verification status.
class KycStatusBanner extends StatelessWidget {
  const KycStatusBanner({super.key, required this.status, this.onTap});

  final KycStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    if (status == KycStatus.verified) return const SizedBox.shrink();

    final config = _config(l10n);

    return AppCard(
      onTap: onTap,
      variant: AppCardVariant.flat,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: config
          .color(colors)
          .withValues(alpha: colors.isDark ? 0.28 : 0.20),
      backgroundColor: config
          .color(colors)
          .withValues(alpha: colors.isDark ? 0.10 : 0.06),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: config
                  .color(colors)
                  .withValues(alpha: colors.isDark ? 0.15 : 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(config.icon, color: config.color(colors), size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  config.title,
                  variant: AppTextVariant.titleSmall,
                  color: colors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  config.subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          StatusPill(
            label: config.pillLabel,
            tone: config.tone,
            compact: true,
            icon: config.pillIcon,
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
        ],
      ),
    );
  }

  _KycBannerConfig _config(AppLocalizations l10n) {
    switch (status) {
      case KycStatus.none:
      case KycStatus.pending:
      case KycStatus.documentsPending:
        return _KycBannerConfig(
          icon: Icons.person_search_rounded,
          title: l10n.kyc_status_pending_title,
          subtitle: l10n.kyc_status_pending_description,
          pillLabel: l10n.kyc_notStarted,
          pillIcon: Icons.arrow_upward_rounded,
          tone: StatusTone.warning,
          color: (colors) => colors.warningText,
        );
      case KycStatus.submitted:
        return _KycBannerConfig(
          icon: Icons.hourglass_top_rounded,
          title: l10n.kyc_status_submitted_title,
          subtitle: l10n.kyc_status_submitted_description,
          pillLabel: l10n.kyc_pending,
          pillIcon: Icons.schedule_rounded,
          tone: StatusTone.info,
          color: (colors) => colors.infoText,
        );
      case KycStatus.rejected:
        return _KycBannerConfig(
          icon: Icons.error_outline_rounded,
          title: l10n.kyc_status_rejected_title,
          subtitle: l10n.kyc_status_rejected_description,
          pillLabel: l10n.kyc_tryAgain,
          pillIcon: Icons.refresh_rounded,
          tone: StatusTone.danger,
          color: (colors) => colors.errorText,
        );
      case KycStatus.additionalInfoNeeded:
        return _KycBannerConfig(
          icon: Icons.assignment_late_rounded,
          title: l10n.kyc_status_additionalInfo_title,
          subtitle: l10n.kyc_status_additionalInfo_description,
          pillLabel: l10n.kyc_tryAgain,
          pillIcon: Icons.edit_rounded,
          tone: StatusTone.warning,
          color: (colors) => colors.warningText,
        );
      case KycStatus.verified:
        return _KycBannerConfig(
          icon: Icons.verified_user_rounded,
          title: l10n.kyc_status_approved_title,
          subtitle: l10n.kyc_status_approved_description,
          pillLabel: l10n.kyc_verified,
          pillIcon: Icons.check_rounded,
          tone: StatusTone.success,
          color: (colors) => colors.successText,
        );
    }
  }
}

class _KycBannerConfig {
  const _KycBannerConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pillLabel,
    required this.pillIcon,
    required this.tone,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String pillLabel;
  final IconData pillIcon;
  final StatusTone tone;
  final Color Function(ThemeColors colors) color;
}
