import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/theme/theme_provider.dart';
import '../../../domain/enums/index.dart';
import '../../../services/biometric/biometric_service.dart';
import '../../../services/localization/language_provider.dart';
import '../../../state/index.dart';
import '../../../services/currency/currency_provider.dart';
import '../../../services/currency/currency_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

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
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _ProfileCard(onTap: () => context.push('/settings/profile')),

            const SizedBox(height: AppSpacing.xxl),

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
                      color: colors.gold.withOpacity(0.2),
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
              onPressed: () => _showLogoutDialog(context, ref),
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
        ),
      ),
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
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: AppText(
                l10n.action_cancel,
                variant: AppTextVariant.labelLarge,
                color: dialogColors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              child: AppText(
                l10n.auth_logout,
                variant: AppTextVariant.labelLarge,
                color: dialogColors.errorText,
              ),
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
        subtitleColor = AppColors.successText;
        icon = Icons.verified_user;
      case KycStatus.pending:
        subtitle = l10n.kyc_pending;
        subtitleColor = AppColors.warningBase;
        icon = Icons.hourglass_top;
      case KycStatus.rejected:
        subtitle = l10n.kyc_rejected;
        subtitleColor = AppColors.errorText;
        icon = Icons.error_outline;
      case KycStatus.none:
        subtitle = l10n.kyc_notStarted;
        subtitleColor = AppColors.textTertiary;
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
                final service = ref.read(biometricServiceProvider);
                if (value) {
                  final authenticated = await service.authenticate(
                    reason: 'Authenticate to enable biometric login',
                  );
                  if (authenticated) {
                    await service.enableBiometric();
                    ref.invalidate(biometricEnabledProvider);
                  }
                } else {
                  await service.disableBiometric();
                  ref.invalidate(biometricEnabledProvider);
                }
              },
              activeColor: AppColors.gold500,
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

/// Theme selector tile with Light/Dark/System options
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
          // Avatar with initials
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.goldGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: AppShadows.goldGlow,
            ),
            child: Center(
              child: AppText(
                _getInitials(userState),
                variant: AppTextVariant.titleLarge,
                color: AppColors.textInverse,
              ),
            ),
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
