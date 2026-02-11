import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/localization/language_provider.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/services/currency/currency_provider.dart';
import 'package:usdc_wallet/services/currency/currency_service.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

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
            _ProfileCard(onTap: () => context.push('/settings/profile')),

            const SizedBox(height: AppSpacing.xxl),

            // ACCOUNT SECTION
            _SectionHeader(l10n.settings_profile),
            const SizedBox(height: AppSpacing.md),
            _SettingsTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () => context.push('/settings/profile/edit'),
            ),
            _KycTile(onTap: () => context.push('/settings/kyc')),

            const SizedBox(height: AppSpacing.xxl),

            // SECURITY SECTION
            _SectionHeader(l10n.settings_security),
            const SizedBox(height: AppSpacing.md),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Change PIN',
              subtitle: 'Update your 4-digit security PIN',
              onTap: () => context.push('/settings/pin'),
            ),
            const _BiometricTile(),
            _SettingsTile(
              icon: Icons.devices,
              title: l10n.settings_devices,
              subtitle: 'Manage trusted devices',
              onTap: () => context.push('/settings/devices'),
            ),
            _SettingsTile(
              icon: Icons.history,
              title: 'Active Sessions',
              subtitle: 'View and manage active sessions',
              onTap: () => context.push('/settings/sessions'),
            ),
            _SettingsTile(
              icon: Icons.security,
              title: l10n.settings_securitySettings,
              subtitle: l10n.settings_securityDescription,
              onTap: () => context.push('/settings/security'),
            ),
            _SettingsTile(
              icon: Icons.speed,
              title: l10n.settings_transactionLimits,
              subtitle: l10n.settings_limitsDescription,
              onTap: () => context.push('/settings/limits'),
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
              subtitle: 'Manage notification preferences',
              onTap: () => context.push('/settings/notifications'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ABOUT SECTION
            _SectionHeader('About'),
            const SizedBox(height: AppSpacing.md),
            _SettingsTile(
              icon: Icons.help_outline,
              title: l10n.settings_helpSupport,
              subtitle: l10n.settings_helpDescription,
              onTap: () => context.push('/settings/help'),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'View our terms',
              onTap: () => _openExternalLink('https://joonapay.com/terms'),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () => _openExternalLink('https://joonapay.com/privacy'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Referral Card - Gold accent
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

            // ACCOUNT ACTIONS
            // Logout Button
            AppButton(
              label: 'Logout',
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
                  'Version $_appVersion',
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
              'Environment: ${const String.fromEnvironment('ENV', defaultValue: 'dev')}',
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Mock Mode: Active',
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  void _openExternalLink(String url) {
    // In production, use url_launcher package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText('Opening: $url'),
        backgroundColor: AppColors.infoBase,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: dialogColors.container,
          title: AppText(
            'Logout',
            variant: AppTextVariant.titleMedium,
            color: dialogColors.textPrimary,
          ),
          content: AppText(
            'Are you sure you want to logout?',
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
              label: 'Logout',
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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

// ══════════════════════════════════════════════════════════════════════════════
// KYC TILE - Shows verification status with badge
// ══════════════════════════════════════════════════════════════════════════════

class _KycTile extends ConsumerWidget {
  const _KycTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycStatus = ref.watch(kycStatusProvider);

    String subtitle;
    Color subtitleColor;
    IconData icon;

    switch (kycStatus) {
      case KycStatus.verified:
        subtitle = 'Verified';
        subtitleColor = AppColors.successText;
        icon = Icons.verified_user;
      case KycStatus.submitted:
        subtitle = 'Under Review';
        subtitleColor = AppColors.warningBase;
        icon = Icons.hourglass_top;
      case KycStatus.pending:
      case KycStatus.documentsPending:
        subtitle = 'Documents Pending';
        subtitleColor = AppColors.warningBase;
        icon = Icons.upload_file;
      case KycStatus.rejected:
        subtitle = 'Rejected - Retry';
        subtitleColor = AppColors.errorText;
        icon = Icons.error_outline;
      case KycStatus.additionalInfoNeeded:
        subtitle = 'More Info Required';
        subtitleColor = AppColors.warningBase;
        icon = Icons.info_outline;
      case KycStatus.none:
        subtitle = 'Not Started';
        subtitleColor = context.colors.textTertiary;
        icon = Icons.verified_user_outlined;
    }

    return _SettingsTile(
      icon: icon,
      title: 'KYC Verification',
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

    return biometricType.when(
      data: (type) {
        if (type == BiometricType.none) {
          return const SizedBox.shrink();
        }

        return biometricEnabled.when(
          data: (enabled) => _SettingsTile(
            icon: type == BiometricType.faceId ? Icons.face : Icons.fingerprint,
            title: type == BiometricType.faceId ? 'Face ID' : 'Touch ID',
            subtitle: enabled ? 'Enabled for login' : 'Tap to enable',
            trailing: Switch(
              value: enabled,
              onChanged: (value) async {
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
              activeThumbColor: AppColors.gold500,
            ),
            onTap: () {},
          ),
          loading: () => _SettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Loading...',
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
    final currentLanguageName = ref
        .read(localeProvider.notifier)
        .getLanguageName(localeState.locale.languageCode);

    return _SettingsTile(
      icon: Icons.language,
      title: 'Language',
      subtitle: currentLanguageName,
      onTap: () => context.push('/settings/language'),
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

    String subtitle = 'USDC';
    if (currencyState.shouldShowReference) {
      subtitle = 'USDC + ${currencyState.referenceCurrency.code}';
    }

    return _SettingsTile(
      icon: Icons.attach_money,
      title: 'Currency Display',
      subtitle: subtitle,
      onTap: () => context.push('/settings/currency'),
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

    String getThemeLabel(AppThemeMode mode) {
      switch (mode) {
        case AppThemeMode.light:
          return 'Light';
        case AppThemeMode.dark:
          return 'Dark';
        case AppThemeMode.system:
          return 'System';
      }
    }

    return _SettingsTile(
      icon: Icons.brightness_6,
      title: 'Theme',
      subtitle: getThemeLabel(themeState.mode),
      onTap: () => _showThemeDialog(context, ref, themeState.mode),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, AppThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.colors.container,
        title: AppText(
          'Select Theme',
          variant: AppTextVariant.titleMedium,
          color: dialogContext.colors.textPrimary,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              mode: AppThemeMode.light,
              currentMode: currentMode,
              icon: Icons.light_mode,
              label: 'Light',
              onTap: () {
                Navigator.pop(dialogContext);
                ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.light);
              },
            ),
            _ThemeOption(
              mode: AppThemeMode.dark,
              currentMode: currentMode,
              icon: Icons.dark_mode,
              label: 'Dark',
              onTap: () {
                Navigator.pop(dialogContext);
                ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.dark);
              },
            ),
            _ThemeOption(
              mode: AppThemeMode.system,
              currentMode: currentMode,
              icon: Icons.brightness_auto,
              label: 'System',
              onTap: () {
                Navigator.pop(dialogContext);
                ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.system);
              },
            ),
          ],
        ),
      ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? colors.gold : colors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppText(
                  label,
                  variant: AppTextVariant.bodyLarge,
                  color: isSelected ? colors.gold : colors.textPrimary,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colors.gold,
                  size: 20,
                ),
            ],
          ),
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
                      const Icon(
                        Icons.verified,
                        color: AppColors.successBase,
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
