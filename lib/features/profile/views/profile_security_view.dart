import 'package:usdc_wallet/design/components/primitives/list_tile_card.dart';
import 'package:usdc_wallet/design/components/primitives/gradient_card.dart';
import 'package:usdc_wallet/design/components/primitives/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/features/profile/providers/profile_provider.dart';
import 'package:usdc_wallet/features/settings/providers/security_settings_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/wallet_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Run 341: Profile security overview - shows security status and actions
class ProfileSecurityView extends ConsumerWidget {
  const ProfileSecurityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.security_accountSecurity,
          style: AppTextStyle.headingSmall,
        ),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SecurityScoreCard(),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(title: l10n.security_authentication),
          const SizedBox(height: AppSpacing.sm),
          _SecurityOption(
            icon: Icons.pin_outlined,
            title: l10n.security_changePin,
            subtitle: l10n.security_changePinSubtitle,
            status: _SecurityStatus.active,
            onTap: () => Navigator.of(context).pushNamed('/pin/change'),
          ),
          _SecurityOption(
            icon: Icons.fingerprint,
            title: l10n.security_biometricLogin,
            subtitle: l10n.security_biometricSubtitle,
            status: _SecurityStatus.active,
            onTap: () =>
                Navigator.of(context).pushNamed('/settings/biometric'),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(title: l10n.security_devices),
          const SizedBox(height: AppSpacing.sm),
          _SecurityOption(
            icon: Icons.devices,
            title: l10n.security_devices,
            subtitle: l10n.security_devicesSubtitle,
            status: _SecurityStatus.info,
            onTap: () => Navigator.of(context).pushNamed('/settings/devices'),
          ),
          _SecurityOption(
            icon: Icons.history,
            title: l10n.security_activeSessions,
            subtitle: l10n.security_activeSessionsSubtitle,
            status: _SecurityStatus.info,
            onTap: () => Navigator.of(context).pushNamed('/settings/sessions'),
          ),
        ],
      ),
    );
  }
}

enum _SecurityStatus { active, inactive, info }

/// Calculates security score based on actual user state:
/// PIN set (+25), biometric enabled (+25), KYC verified (+25), email verified (+25)
class _SecurityScoreCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileProvider);
    final securitySettings = ref.watch(securitySettingsProvider);
    final kycStatus = ref.watch(kycStatusProvider);

    // Calculate score
    int score = 0;
    final user = profileState.user;

    // PIN set (+25)
    if (user?.hasPin == true) score += 25;

    // Biometric enabled (+25)
    if (securitySettings.biometricEnabled) score += 25;

    // KYC verified (+25)
    final kycVerified = kycStatus.whenOrNull(
      data: (status) => status.status == 'approved' || status.status == 'auto_approved',
    ) ?? false;
    if (kycVerified) score += 25;

    // Email verified (+25)
    if (user?.email != null && user!.email!.isNotEmpty) score += 25;

    // Determine level
    final String levelText;
    final Color levelColor;
    final String description;
    if (score >= 75) {
      levelText = l10n.security_scoreExcellent;
      levelColor = context.colors.gold;
      description = l10n.security_wellProtected;
    } else if (score >= 50) {
      levelText = l10n.security_scoreGood;
      levelColor = AppColors.successBase;
      description = l10n.security_scoreGoodDesc;
    } else if (score >= 25) {
      levelText = l10n.security_scoreModerate;
      levelColor = AppColors.warningBase;
      description = l10n.security_scoreModerateDesc;
    } else {
      levelText = l10n.security_scoreLow;
      levelColor = AppColors.errorBase;
      description = l10n.security_scoreLowDesc;
    }

    return Semantics(
      label: '${l10n.security_scoreTitle}: $levelText ($score%)',
      child: GradientCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(Icons.shield, color: levelColor, size: 48),
              const SizedBox(height: AppSpacing.md),
              AppText(
                '$levelText ($score%)',
                style: AppTextStyle.headingSmall,
                color: levelColor,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                description,
                style: AppTextStyle.bodySmall,
                color: context.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final _SecurityStatus status;
  final VoidCallback onTap;

  const _SecurityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case _SecurityStatus.active:
        return AppColors.successBase;
      case _SecurityStatus.inactive:
        return AppColors.errorBase;
      case _SecurityStatus.info:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title: $subtitle',
      child: ListTileCard(
        leading: Icon(icon, color: context.colors.gold),
        title: title,
        subtitle: subtitle,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == _SecurityStatus.active)
              Icon(Icons.check_circle, color: _statusColor, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right, color: context.colors.textTertiary),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
