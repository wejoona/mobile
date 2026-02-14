import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/utils/responsive_layout.dart';
import 'package:usdc_wallet/core/orientation/orientation_helper.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/localization/language_provider.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/services/currency/currency_provider.dart';
import 'package:usdc_wallet/services/currency/currency_service.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/business/providers/business_provider.dart';
import 'package:usdc_wallet/domain/enums/account_type.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final localeState = ref.watch(localeProvider);
    final currentLanguageName = ref
        .read(localeProvider.notifier)
        .getLanguageName(localeState.locale.languageCode);
    final isLandscape = OrientationHelper.isLandscape(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.navigation_settings,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/home'),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedContent(
          child: Padding(
            padding: OrientationHelper.padding(
              context,
              portrait: ResponsiveLayout.padding(
                context,
                mobile: const EdgeInsets.all(AppSpacing.screenPadding),
                tablet: const EdgeInsets.all(AppSpacing.xl),
              ),
              landscape: ResponsiveLayout.padding(
                context,
                mobile: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                tablet: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
              ),
            ),
            child: isLandscape
                ? _buildLandscapeLayout(context, ref, l10n, colors, currentLanguageName)
                : ResponsiveBuilder(
                    mobile: _buildMobileLayout(context, ref, l10n, colors, currentLanguageName),
                    tablet: _buildTabletLayout(context, ref, l10n, colors, currentLanguageName),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
    String currentLanguageName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileCard(onTap: () => context.push('/settings/profile')),
        const SizedBox(height: AppSpacing.xxl),
        _buildSettingsSections(context, l10n, colors, currentLanguageName, ref),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
    String currentLanguageName,
  ) {
    return Column(
      children: [
        // Profile Card full-width on tablet
        _ProfileCard(onTap: () => context.push('/settings/profile')),
        const SizedBox(height: AppSpacing.xxl),

        // Two-column layout for settings sections
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Security Section
                  AppText(
                    l10n.settings_security,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsTile(
                    icon: Icons.security,
                    title: l10n.settings_securitySettings,
                    subtitle: l10n.settings_securityDescription,
                    onTap: () => context.push('/settings/security'),
                  ),
                  _KycTile(onTap: () => context.push('/settings/kyc')),
                  _SettingsTile(
                    icon: Icons.speed,
                    title: l10n.settings_transactionLimits,
                    subtitle: l10n.settings_limitsDescription,
                    onTap: () => context.push('/settings/limits'),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Account Section
                  AppText(
                    l10n.settings_account,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _AccountTypeTile(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xxl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preferences Section
                  AppText(
                    l10n.settings_preferences,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: l10n.settings_notifications,
                    onTap: () => context.push('/settings/notifications'),
                  ),
                  _SettingsTile(
                    icon: Icons.language,
                    title: l10n.settings_language,
                    subtitle: currentLanguageName,
                    onTap: () => context.push('/settings/language'),
                  ),
                  const _ThemeTile(),
                  const _CurrencyTile(),

                  const SizedBox(height: AppSpacing.xxl),

                  // Support Section
                  AppText(
                    l10n.settings_support,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: l10n.settings_helpSupport,
                    subtitle: l10n.settings_helpDescription,
                    onTap: () => context.push('/settings/help'),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Referral Card - full width
        AppCard(
          variant: AppCardVariant.goldAccent,
          onTap: () => context.push('/referrals'),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: colors.gold,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.settings_referEarn,
                      variant: AppTextVariant.titleSmall,
                      color: colors.gold,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      l10n.settings_referDescription,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.gold,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // Logout Button - centered on tablet
        SizedBox(
          width: 400,
          child: AppButton(
            label: l10n.auth_logout,
            onPressed: () => _showLogoutDialog(context, ref!),
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Version
        Center(
          child: AppText(
            l10n.settings_version('1.0.0'),
            variant: AppTextVariant.labelSmall,
            color: colors.textTertiary,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  /// Landscape layout: Three-column grid for better space usage
  Widget _buildLandscapeLayout(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
    String currentLanguageName,
  ) {
    return Column(
      children: [
        // Profile Card - full width but more compact
        _ProfileCard(onTap: () => context.push('/settings/profile')),
        const SizedBox(height: AppSpacing.xl),

        // Three-column grid layout for settings
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Column 1: Security
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.settings_security,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SettingsTile(
                    icon: Icons.security,
                    title: l10n.settings_securitySettings,
                    subtitle: l10n.settings_securityDescription,
                    onTap: () => context.push('/settings/security'),
                  ),
                  _KycTile(onTap: () => context.push('/settings/kyc')),
                  _SettingsTile(
                    icon: Icons.speed,
                    title: l10n.settings_transactionLimits,
                    subtitle: l10n.settings_limitsDescription,
                    onTap: () => context.push('/settings/limits'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            // Column 2: Preferences
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.settings_preferences,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: l10n.settings_notifications,
                    onTap: () => context.push('/settings/notifications'),
                  ),
                  _SettingsTile(
                    icon: Icons.language,
                    title: l10n.settings_language,
                    subtitle: currentLanguageName,
                    onTap: () => context.push('/settings/language'),
                  ),
                  const _ThemeTile(),
                  const _CurrencyTile(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            // Column 3: Account & Support
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.settings_account,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _AccountTypeTile(),
                  const SizedBox(height: AppSpacing.lg),
                  AppText(
                    l10n.settings_support,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: l10n.settings_helpSupport,
                    subtitle: l10n.settings_helpDescription,
                    onTap: () => context.push('/settings/help'),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // Referral Card - centered, constrained width
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AppCard(
              variant: AppCardVariant.goldAccent,
              onTap: () => context.push('/referrals'),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.card_giftcard,
                      color: colors.gold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          l10n.settings_referEarn,
                          variant: AppTextVariant.titleSmall,
                          color: colors.gold,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          l10n.settings_referDescription,
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colors.gold,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Logout Button - centered, constrained width
        Center(
          child: SizedBox(
            width: 300,
            child: AppButton(
              label: l10n.auth_logout,
              onPressed: () => _showLogoutDialog(context, ref!),
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Version
        Center(
          child: AppText(
            l10n.settings_version('1.0.0'),
            variant: AppTextVariant.labelSmall,
            color: colors.textTertiary,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildSettingsSections(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
    String currentLanguageName, [
    WidgetRef? ref,
  ]) {
    // ignore: unnecessary_non_null_assertion
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Security Section
        AppText(
          l10n.settings_security,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        _SettingsTile(
          icon: Icons.security,
          title: l10n.settings_securitySettings,
          subtitle: l10n.settings_securityDescription,
          onTap: () => context.push('/settings/security'),
        ),
        _KycTile(onTap: () => context.push('/settings/kyc')),
        _SettingsTile(
          icon: Icons.speed,
          title: l10n.settings_transactionLimits,
          subtitle: l10n.settings_limitsDescription,
          onTap: () => context.push('/settings/limits'),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Account Section
        AppText(
          l10n.settings_account,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        const _AccountTypeTile(),

        const SizedBox(height: AppSpacing.xxl),

        // Preferences Section
        AppText(
          l10n.settings_preferences,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        _SettingsTile(
          icon: Icons.notifications_outlined,
          title: l10n.settings_notifications,
          onTap: () => context.push('/settings/notifications'),
        ),
        _SettingsTile(
          icon: Icons.language,
          title: l10n.settings_language,
          subtitle: currentLanguageName,
          onTap: () => context.push('/settings/language'),
        ),
        const _ThemeTile(),
        const _CurrencyTile(),

        const SizedBox(height: AppSpacing.xxl),

        // Support Section
        AppText(
          l10n.settings_support,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        _SettingsTile(
          icon: Icons.help_outline,
          title: l10n.settings_helpSupport,
          subtitle: l10n.settings_helpDescription,
          onTap: () => context.push('/settings/help'),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Referral
        AppCard(
          variant: AppCardVariant.goldAccent,
          onTap: () => context.push('/referrals'),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: colors.gold,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.settings_referEarn,
                      variant: AppTextVariant.titleSmall,
                      color: colors.gold,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      l10n.settings_referDescription,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.gold,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // Logout Button
        AppButton(
          label: l10n.auth_logout,
          onPressed: () => _showLogoutDialog(context, ref!),
          variant: AppButtonVariant.secondary,
          isFullWidth: true,
        ),

        const SizedBox(height: AppSpacing.lg),

        // Version
        Center(
          child: AppText(
            l10n.settings_version('1.0.0'),
            variant: AppTextVariant.labelSmall,
            color: colors.textTertiary,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: dialogColors.container,
          title: AppText(
            l10n.auth_logout,
            variant: AppTextVariant.titleMedium,
            color: dialogColors.textPrimary,
          ),
          content: AppText(
            l10n.auth_logoutConfirm,
            variant: AppTextVariant.bodyMedium,
            color: dialogColors.textSecondary,
          ),
          actions: [
            AppButton(
              label: l10n.action_cancel,
              onPressed: () => Navigator.pop(dialogContext),
              variant: AppButtonVariant.ghost,
              size: AppButtonSize.small,
            ),
            AppButton(
              label: l10n.auth_logout,
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              variant: AppButtonVariant.danger,
              size: AppButtonSize.small,
            ),
          ],
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          hapticService.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: colors.textSecondary, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppText(
                  title,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textPrimary,
                ),
              ),
              if (subtitle != null)
                AppText(
                  subtitle!,
                  variant: AppTextVariant.bodyMedium,
                  color: subtitleColor ?? colors.textTertiary,
                ),
              if (trailing != null) trailing!,
              if (trailing == null && subtitle == null)
                Icon(
                  Icons.chevron_right,
                  color: colors.textTertiary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KycTile extends ConsumerWidget {
  const _KycTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final kycStatus = ref.watch(kycStatusProvider);

    String subtitle;
    Color subtitleColor;
    IconData icon;

    switch (kycStatus) {
      case KycStatus.verified:
        subtitle = l10n.kyc_verified;
        subtitleColor = context.colors.successText;
        icon = Icons.verified_user;
      case KycStatus.submitted:
        subtitle = l10n.kyc_pending;
        subtitleColor = context.colors.warning;
        icon = Icons.hourglass_top;
      case KycStatus.pending:
      case KycStatus.documentsPending:
        subtitle = l10n.kyc_pending;
        subtitleColor = context.colors.warning;
        icon = Icons.upload_file;
      case KycStatus.rejected:
        subtitle = l10n.kyc_rejected;
        subtitleColor = context.colors.errorText;
        icon = Icons.error_outline;
      case KycStatus.additionalInfoNeeded:
        subtitle = l10n.kyc_pending;
        subtitleColor = context.colors.warning;
        icon = Icons.info_outline;
      case KycStatus.none:
        subtitle = l10n.kyc_notStarted;
        subtitleColor = context.colors.textTertiary;
        icon = Icons.verified_user_outlined;
    }

    return _SettingsTile(
      icon: icon,
      title: l10n.settings_kycVerification,
      subtitle: subtitle,
      subtitleColor: subtitleColor,
      onTap: onTap,
    );
  }
}

class _BiometricTile extends ConsumerWidget {
  const _BiometricTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricType = ref.watch(primaryBiometricTypeProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return biometricType.when(
      data: (type) {
        if (type == BiometricType.none) {
          return const SizedBox.shrink();
        }

        return biometricEnabled.when(
          data: (enabled) => _SettingsTile(
            icon: type == BiometricType.faceId ? Icons.face : Icons.fingerprint,
            title: type == BiometricType.faceId ? 'Face ID' : 'Touch ID',
            trailing: Switch(
              value: enabled,
              onChanged: (value) async {
                // Haptic feedback on toggle
                hapticService.toggle();

                final service = ref.read(biometricServiceProvider);
                if (value) {
                  final authenticatedBio = await service.authenticate(
                    localizedReason: 'Authenticate to enable biometric login',
                  );
                  if (authenticatedBio.success) {
                    await service.enableBiometric();
                    ref.invalidate(biometricEnabledProvider);
                  }
                } else {
                  await service.disableBiometric();
                  ref.invalidate(biometricEnabledProvider);
                }
              },
              activeColor: context.colors.gold,
            ),
            onTap: () {},
          ),
          loading: () => _SettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            trailing: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            onTap: () {},
          ),
          error: (_, __) => _SettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Error',
            onTap: () {},
          ),
        );
      },
      loading: () => _SettingsTile(
        icon: Icons.fingerprint,
        title: 'Biometric Login',
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        onTap: () {},
      ),
      error: (_, __) => _SettingsTile(
        icon: Icons.fingerprint,
        title: 'Biometric Login',
        subtitle: 'Error',
        onTap: () {},
      ),
    );
  }
}

/// Theme selector tile - navigates to theme settings
class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = ref.watch(themeProvider);

    String getThemeLabel(AppThemeMode mode) {
      switch (mode) {
        case AppThemeMode.light:
          return l10n.settings_themeLight;
        case AppThemeMode.dark:
          return l10n.settings_themeDark;
        case AppThemeMode.system:
          return l10n.settings_themeSystem;
      }
    }

    return _SettingsTile(
      icon: Icons.brightness_6,
      title: l10n.settings_appearance,
      subtitle: getThemeLabel(themeState.mode),
      onTap: () => context.push('/settings/theme'),
    );
  }
}

/// Profile Card showing user avatar, name, phone and verification status
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final userState = ref.watch(userStateMachineProvider);
    final kycStatus = ref.watch(kycStatusProvider);

    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: onTap,
      child: Row(
        children: [
          // Avatar with profile image or initials
          UserAvatar(
            imageUrl: userState.avatarUrl,
            firstName: userState.firstName,
            lastName: userState.lastName,
            size: 56,
            showBorder: true,
            borderColor: colors.gold,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name with verified badge
                Row(
                  children: [
                    Flexible(
                      child: AppText(
                        userState.displayName,
                        variant: AppTextVariant.titleMedium,
                        color: colors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (kycStatus == KycStatus.verified) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.verified,
                        color: context.colors.success,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                // Phone number
                AppText(
                  _formatPhone(userState.phone),
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: colors.textTertiary,
          ),
        ],
      ),
    );
  }

  String _getInitials(UserState userState) {
    final firstName = userState.firstName;
    final lastName = userState.lastName;

    if (firstName != null && firstName.isNotEmpty && lastName != null && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName != null && firstName.isNotEmpty) {
      return firstName.substring(0, firstName.length >= 2 ? 2 : 1).toUpperCase();
    } else if (userState.phone != null && userState.phone!.length >= 2) {
      return userState.phone!.substring(userState.phone!.length - 2);
    }
    return 'U';
  }

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    // Format: +225 XX XX XX XX
    if (phone.startsWith('+') && phone.length > 6) {
      final countryCode = phone.substring(0, 4); // +225
      final number = phone.substring(4);
      // Insert spaces every 2 digits
      final formatted = number.replaceAllMapped(
        RegExp(r'.{2}'),
        (match) => '${match.group(0)} ',
      );
      return '$countryCode $formatted'.trim();
    }
    return phone;
  }
}

/// Currency tile showing USDC + optional reference currency
class _CurrencyTile extends ConsumerWidget {
  const _CurrencyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currencyState = ref.watch(currencyProvider);

    String subtitle = 'USDC';
    if (currencyState.shouldShowReference) {
      subtitle = 'USDC + ${currencyState.referenceCurrency.code}';
    }

    return _SettingsTile(
      icon: Icons.attach_money,
      title: l10n.settings_defaultCurrency,
      subtitle: subtitle,
      onTap: () => context.push('/settings/currency'),
    );
  }
}

/// Account Type Tile - toggle between Personal and Business
class _AccountTypeTile extends ConsumerWidget {
  const _AccountTypeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final businessState = ref.watch(businessProvider);

    return _SettingsTile(
      icon: businessState.isBusinessAccount ? Icons.business : Icons.person,
      title: l10n.settings_accountType,
      subtitle: businessState.isBusinessAccount
          ? l10n.settings_businessAccount
          : l10n.settings_personalAccount,
      onTap: () => _showAccountTypeSwitcher(context, ref, l10n, businessState),
    );
  }

  void _showAccountTypeSwitcher(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    BusinessState state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetContext.colors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            AppText(
              l10n.settings_selectAccountType,
              variant: AppTextVariant.titleMedium,
              color: sheetContext.colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Personal Account Option
            _AccountTypeOption(
              type: AccountType.personal,
              currentType: state.accountType,
              icon: Icons.person,
              title: l10n.settings_personalAccount,
              description: l10n.settings_personalAccountDescription,
              onTap: () async {
                Navigator.pop(sheetContext);
                final success = await ref
                    .read(businessProvider.notifier)
                    .switchAccountType(AccountType.personal);
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.settings_switchedToPersonal),
                      backgroundColor: context.colors.success,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Business Account Option
            _AccountTypeOption(
              type: AccountType.business,
              currentType: state.accountType,
              icon: Icons.business,
              title: l10n.settings_businessAccount,
              description: l10n.settings_businessAccountDescription,
              onTap: () async {
                Navigator.pop(sheetContext);

                // Check if business profile exists
                if (state.businessProfile == null) {
                  // Navigate to setup
                  context.push('/settings/business-setup');
                } else {
                  // Switch to business
                  final success = await ref
                      .read(businessProvider.notifier)
                      .switchAccountType(AccountType.business);
                  if (context.mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.settings_switchedToBusiness),
                        backgroundColor: context.colors.success,
                      ),
                    );
                  }
                }
              },
            ),
            SizedBox(height: MediaQuery.of(sheetContext).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _AccountTypeOption extends StatelessWidget {
  const _AccountTypeOption({
    required this.type,
    required this.currentType,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final AccountType type;
  final AccountType currentType;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSelected = type == currentType;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? colors.gold : colors.textTertiary.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.gold.withValues(alpha: 0.2)
                      : colors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? colors.gold : colors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      variant: AppTextVariant.titleSmall,
                      color: isSelected ? colors.gold : colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      description,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colors.gold,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
