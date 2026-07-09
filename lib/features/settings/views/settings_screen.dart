import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/settings/utils/profile_phone_formatter.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/currency/currency_provider.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_service.dart';
import 'package:usdc_wallet/services/feature_flags/feature_gate.dart';
import 'package:usdc_wallet/services/currency/currency_service.dart';
import 'package:usdc_wallet/services/localization/language_provider.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Comprehensive Settings Screen
/// Integrates profile, security, preferences, devices, sessions, and support
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  int _debugTapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(kycStateMachineProvider.notifier).fetch());
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.navigation_settings,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card - shows user info, KYC status
            _ProfileCard(onTap: () => context.fsmPush('/settings/profile')),

            const SizedBox(height: AppSpacing.xxl),

            // ACCOUNT SECTION
            _SectionHeader(l10n.settings_profile),
            const SizedBox(height: AppSpacing.md),
            _SettingsTile(
              icon: Icons.edit_outlined,
              title: l10n.settings_profile,
              subtitle: l10n.settings_profileDescription,
              onTap: () => context.fsmPush('/settings/profile/edit'),
            ),
            _KycTile(onTap: () => context.fsmPush('/settings/kyc')),

            const SizedBox(height: AppSpacing.xxl),

            // SECURITY SECTION
            _SectionHeader(l10n.settings_security),
            const SizedBox(height: AppSpacing.md),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: l10n.pin_changeTitle,
              subtitle: l10n.settings_securityDescription,
              onTap: () => context.fsmPush('/settings/pin'),
            ),
            const _BiometricTile(),
            _SettingsTile(
              icon: Icons.devices,
              title: l10n.settings_devices,
              subtitle: l10n.settings_devicesDescription,
              onTap: () => context.fsmPush('/settings/devices'),
            ),
            _SettingsTile(
              icon: Icons.history,
              title: l10n.settings_activeSessions,
              subtitle: l10n.security_activeSessionsSubtitle,
              onTap: () => context.fsmPush('/settings/sessions'),
            ),
            _SettingsTile(
              icon: Icons.security,
              title: l10n.settings_securitySettings,
              subtitle: l10n.settings_securityDescription,
              onTap: () => context.fsmPush('/settings/security'),
            ),
            _SettingsTile(
              icon: Icons.speed,
              title: l10n.settings_transactionLimits,
              subtitle: l10n.settings_limitsDescription,
              onTap: () => context.fsmPush('/settings/limits'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // PREFERENCES SECTION
            _SectionHeader(l10n.settings_preferences),
            const SizedBox(height: AppSpacing.md),
            _LanguageTile(),
            const _CurrencyTile(),
            const _ThemeTile(),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: l10n.settings_notifications,
              subtitle: l10n.notifications_transactionsDescription,
              onTap: () => context.fsmPush('/settings/notifications'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ABOUT SECTION
            _SectionHeader(l10n.settings_about),
            const SizedBox(height: AppSpacing.md),
            _SettingsTile(
              icon: Icons.help_outline,
              title: l10n.settings_helpSupport,
              subtitle: l10n.settings_helpDescription,
              onTap: () => context.fsmPush('/settings/help'),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: l10n.settings_termsOfService,
              onTap: () => _openExternalLink('https://joonapay.com/terms'),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: l10n.settings_privacyPolicy,
              onTap: () => _openExternalLink('https://joonapay.com/privacy'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Referral Card - Gold accent (hidden when referrals disabled)
            AnyFeatureGate(
              flags: const [
                FeatureFlagKeys.referrals,
                FeatureFlagKeys.referralProgram,
              ],
              child: AppCard(
                variant: AppCardVariant.goldAccent,
                onTap: () => context.fsmPush('/referrals'),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(Icons.card_giftcard, color: colors.gold),
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
                    Icon(Icons.chevron_right, color: colors.gold),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // ACCOUNT ACTIONS
            // Logout Button
            AppButton(
              key: const ValueKey('settings_logout_button'),
              label: l10n.common_logout,
              onPressed: () => _showLogoutDialog(context, ref, l10n),
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Version - tap 7 times for debug menu
            Center(
              child: GestureDetector(
                onTap: _handleVersionTap,
                child: AppText(
                  l10n.settings_version(_appVersion),
                  variant: AppTextVariant.labelSmall,
                  color: colors.textTertiary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _handleVersionTap() {
    if (!kDebugMode) {
      return;
    }

    setState(() {
      _debugTapCount++;
    });

    if (_debugTapCount >= 7) {
      _showDebugMenu();
      setState(() {
        _debugTapCount = 0;
      });
    }
  }

  void _showDebugMenu() {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.container,
        title: AppText(
          'Debug Menu',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'App Version: $_appVersion',
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Environment: ${EnvironmentConfig.environment}',
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Mock Mode: ${MockConfig.useMocks ? 'Enabled' : 'Disabled'}',
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ],
        ),
        actions: [
          AppButton(
            label: l10n.common_close,
            onPressed: () => Navigator.pop(context),
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  Future<void> _openExternalLink(String url) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final colors = context.colors;
    final uri = Uri.parse(url);

    messenger.showSnackBar(
      SnackBar(
        content: AppText(l10n.settings_openingUrl(url)),
        backgroundColor: colors.info,
      ),
    );

    final launched = await _tryLaunch(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || launched) return;

    messenger.showSnackBar(
      SnackBar(
        content: AppText(l10n.error_generic),
        backgroundColor: colors.error,
      ),
    );
  }

  Future<bool> _tryLaunch(Uri uri, {required LaunchMode mode}) async {
    try {
      return launchUrl(uri, mode: mode);
    } on Object {
      return false;
    }
  }

  void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: dialogColors.container,
          title: AppText(
            l10n.common_logout,
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
              key: const ValueKey('settings_logout_confirm_button'),
              label: l10n.common_logout,
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authProvider.notifier).logout();
                context.fsmGo('/login');
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

// ══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppText(
      title.toUpperCase(),
      variant: AppTextVariant.labelMedium,
      color: colors.textSecondary,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SETTINGS TILE
// ══════════════════════════════════════════════════════════════════════════════

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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.flat,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        borderRadius: AppRadius.lg,
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: colors.gold, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textPrimary,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      subtitle!,
                      variant: AppTextVariant.bodySmall,
                      color: subtitleColor ?? colors.textTertiary,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(Icons.chevron_right, color: colors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// KYC TILE - Shows verification status with badge
// ══════════════════════════════════════════════════════════════════════════════

class _KycTile extends ConsumerWidget {
  const _KycTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycStatus = ref.watch(effectiveKycStatusProvider);
    final l10n = AppLocalizations.of(context)!;

    String subtitle;
    Color subtitleColor;
    IconData icon;

    switch (kycStatus) {
      case KycStatus.verified:
        subtitle = l10n.kyc_verified;
        subtitleColor = context.colors.successText;
        icon = Icons.verified_user;
      case KycStatus.submitted:
      case KycStatus.manualReview:
        subtitle = l10n.kyc_status_submitted_title;
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
        subtitle = l10n.kyc_status_additionalInfo_title;
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

// ══════════════════════════════════════════════════════════════════════════════
// BIOMETRIC TILE - Toggle for Face ID/Touch ID
// ══════════════════════════════════════════════════════════════════════════════

class _BiometricTile extends ConsumerWidget {
  const _BiometricTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricType = ref.watch(primaryBiometricTypeProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final l10n = AppLocalizations.of(context)!;

    return biometricType.when(
      data: (type) {
        if (type == BiometricType.none) {
          return const SizedBox.shrink();
        }

        return biometricEnabled.when(
          data: (enabled) => _SettingsTile(
            icon: type == BiometricType.faceId ? Icons.face : Icons.fingerprint,
            title: type == BiometricType.faceId
                ? l10n.biometric_type_face_id
                : l10n.biometric_type_fingerprint,
            subtitle: enabled
                ? l10n.biometric_settings_enabled_subtitle
                : l10n.biometric_settings_disabled_subtitle,
            trailing: Switch(
              value: enabled,
              onChanged: (value) async {
                final service = ref.read(biometricServiceProvider);
                if (value) {
                  final authState = ref.read(authProvider);
                  final userId = authState.user?.id;
                  if (userId == null || userId.isEmpty) {
                    return;
                  }
                  final authenticatedBio = await service.authenticate(
                    localizedReason:
                        l10n.biometric_enrollment_authenticate_reason,
                  );
                  if (authenticatedBio.success) {
                    await service.enableBiometric(
                      userId: userId,
                      phone: authState.phone,
                    );
                    ref.invalidate(biometricEnabledProvider);
                  }
                } else {
                  await service.disableBiometric();
                  ref.invalidate(biometricEnabledProvider);
                }
              },
              activeThumbColor: context.colors.gold,
            ),
            onTap: () {},
          ),
          loading: () => _SettingsTile(
            icon: Icons.fingerprint,
            title: l10n.security_biometricLogin,
            subtitle: l10n.common_loading,
            trailing: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            onTap: () {},
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LANGUAGE TILE
// ══════════════════════════════════════════════════════════════════════════════

class _LanguageTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentLanguageName = ref
        .read(localeProvider.notifier)
        .getLanguageName(localeState.locale.languageCode);

    return _SettingsTile(
      icon: Icons.language,
      title: l10n.settings_language,
      subtitle: currentLanguageName,
      onTap: () => context.fsmPush('/settings/language'),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CURRENCY TILE
// ══════════════════════════════════════════════════════════════════════════════

class _CurrencyTile extends ConsumerWidget {
  const _CurrencyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context)!;

    String subtitle = 'USDC';
    if (currencyState.shouldShowReference) {
      subtitle = 'USDC + ${currencyState.referenceCurrency.code}';
    }

    return _SettingsTile(
      icon: Icons.attach_money,
      title: l10n.settings_defaultCurrency,
      subtitle: subtitle,
      onTap: () => context.fsmPush('/settings/currency'),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// THEME TILE
// ══════════════════════════════════════════════════════════════════════════════

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;

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
      title: l10n.settings_theme,
      subtitle: getThemeLabel(themeState.mode),
      onTap: () => _showThemeDialog(context, ref, themeState.mode),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: dialogColors.surface,
          title: AppText(
            l10n.settings_selectTheme,
            variant: AppTextVariant.titleMedium,
            color: dialogColors.textPrimary,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeOption(
                mode: AppThemeMode.light,
                currentMode: currentMode,
                icon: Icons.light_mode,
                label: l10n.settings_themeLight,
                onTap: () {
                  Navigator.pop(dialogContext);
                  ref
                      .read(themeProvider.notifier)
                      .setThemeMode(AppThemeMode.light);
                },
              ),
              _ThemeOption(
                mode: AppThemeMode.dark,
                currentMode: currentMode,
                icon: Icons.dark_mode,
                label: l10n.settings_themeDark,
                onTap: () {
                  Navigator.pop(dialogContext);
                  ref
                      .read(themeProvider.notifier)
                      .setThemeMode(AppThemeMode.dark);
                },
              ),
              _ThemeOption(
                mode: AppThemeMode.system,
                currentMode: currentMode,
                icon: Icons.brightness_auto,
                label: l10n.settings_themeSystem,
                onTap: () {
                  Navigator.pop(dialogContext);
                  ref
                      .read(themeProvider.notifier)
                      .setThemeMode(AppThemeMode.system);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.currentMode,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppThemeMode mode;
  final AppThemeMode currentMode;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSelected = mode == currentMode;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.flat,
        borderRadius: AppRadius.md,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colors.gold : colors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(
                label,
                variant: AppTextVariant.bodyLarge,
                color: isSelected ? colors.gold : colors.textPrimary,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.gold, size: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PROFILE CARD - Shows user avatar, name, phone, verification status
// ══════════════════════════════════════════════════════════════════════════════

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final userState = ref.watch(userStateMachineProvider);
    final kycStatus = ref.watch(effectiveKycStatusProvider);

    return AppCard(
      variant: AppCardVariant.elevated,
      onTap: onTap,
      child: Row(
        children: [
          // Avatar with profile image or initials
          UserAvatar(
            imageUrl: userState.effectiveAvatarUrl,
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
                  formatProfilePhone(userState.phone),
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.textTertiary),
        ],
      ),
    );
  }
}
