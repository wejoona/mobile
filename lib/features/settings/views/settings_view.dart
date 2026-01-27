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
import '../../auth/providers/auth_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeState = ref.watch(localeProvider);
    final currentLanguageName = ref
        .read(localeProvider.notifier)
        .getLanguageName(localeState.locale.languageCode);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.navigation_settings,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold500),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            AppCard(
              variant: AppCardVariant.elevated,
              onTap: () => context.push('/settings/profile'),
              child: Row(
                children: [
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
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textInverse,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          l10n.settings_profile,
                          variant: AppTextVariant.titleMedium,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          l10n.settings_profileDescription,
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Security Section
            AppText(
              l10n.settings_security,
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
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
              color: AppColors.textSecondary,
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
            _SettingsTile(
              icon: Icons.attach_money,
              title: l10n.settings_defaultCurrency,
              subtitle: 'USDC',
              onTap: () {},
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Support Section
            AppText(
              l10n.settings_support,
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
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
                      color: AppColors.gold500.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: AppColors.gold500,
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
                          color: AppColors.gold500,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          l10n.settings_referDescription,
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.gold500,
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
                color: AppColors.textTertiary,
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
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: AppText(
          l10n.auth_logout,
          variant: AppTextVariant.titleMedium,
        ),
        content: AppText(
          l10n.auth_logoutConfirm,
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(
              l10n.action_cancel,
              variant: AppTextVariant.labelLarge,
              color: AppColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: AppText(
              l10n.auth_logout,
              variant: AppTextVariant.labelLarge,
              color: AppColors.errorText,
            ),
          ),
        ],
      ),
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
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppText(
                  title,
                  variant: AppTextVariant.bodyLarge,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null)
                AppText(
                  subtitle!,
                  variant: AppTextVariant.bodyMedium,
                  color: subtitleColor ?? AppColors.textTertiary,
                ),
              if (trailing != null) trailing!,
              if (trailing == null && subtitle == null)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
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
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const AppText(
          'Select Theme',
          variant: AppTextVariant.titleMedium,
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
                ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.light);
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              mode: AppThemeMode.dark,
              currentMode: currentMode,
              icon: Icons.dark_mode,
              label: 'Dark',
              onTap: () {
                ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              mode: AppThemeMode.system,
              currentMode: currentMode,
              icon: Icons.brightness_auto,
              label: 'System',
              onTap: () {
                ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.system);
                Navigator.pop(context);
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
                color: isSelected ? AppColors.gold500 : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppText(
                  label,
                  variant: AppTextVariant.bodyLarge,
                  color: isSelected ? AppColors.gold500 : AppColors.textPrimary,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.gold500,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
