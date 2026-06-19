import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/settings/providers/notification_preferences_provider.dart';
import 'package:usdc_wallet/features/settings/providers/security_settings_provider.dart';
import 'package:usdc_wallet/features/settings/providers/sessions_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';
import 'package:usdc_wallet/utils/context_extensions.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

class SecurityView extends ConsumerStatefulWidget {
  const SecurityView({super.key});

  @override
  ConsumerState<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends ConsumerState<SecurityView> {
  bool _isSubscribingToTwoFactor = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final settings = ref.watch(securitySettingsProvider);
    final settingsNotifier = ref.read(securitySettingsProvider.notifier);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.security_title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.fsmSafePop(fallbackRoute: '/settings'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Score
            _buildSecurityScoreCard(colors),

            const SizedBox(height: AppSpacing.xxl),

            // Authentication Section
            AppText(
              l10n.security_authentication.toUpperCase(),
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSecurityOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.lock_outline,
              title: l10n.security_changePin,
              subtitle: l10n.security_changePinSubtitle,
              onTap: () => context.fsmPush('/settings/pin'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildBiometricOption(l10n, colors),
            const SizedBox(height: AppSpacing.sm),
            _buildToggleOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.lock_clock_rounded,
              title: l10n.security_pinOnAppOpen,
              subtitle: l10n.security_pinOnAppOpenSubtitle,
              value: settings.pinOnAppOpen,
              onChanged: settingsNotifier.setPinOnAppOpen,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildStatusOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.timer_rounded,
              title: l10n.security_autoLock,
              subtitle: l10n.security_autoLockMinutes(settings.autoLockMinutes),
              status: l10n.security_minutesFormat(settings.autoLockMinutes),
              onTap: () => _showAutoLockPicker(l10n),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildFeatureSubscriptionOption(
              colors: colors,
              icon: Icons.security,
              title: l10n.security_twoFactorAuth,
              subtitle: l10n.security_twoFactorComingSoonSubtitle,
              status: l10n.common_comingSoon,
              actionLabel: l10n.security_twoFactorNotifyMe,
              isLoading: _isSubscribingToTwoFactor,
              onTap: () => _subscribeToTwoFactor(l10n),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Transaction Security
            AppText(
              l10n.security_transactionSecurity.toUpperCase(),
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatusOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.pin,
              title: l10n.security_requirePinForTransactions,
              subtitle: l10n.security_requirePinSubtitle,
              status: l10n.notifications_required,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Alerts Section
            AppText(
              l10n.security_alerts.toUpperCase(),
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTransactionAlertOption(l10n: l10n, colors: colors),
            const SizedBox(height: AppSpacing.sm),
            _buildSecurityAlertOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.login,
              title: l10n.security_loginNotifications,
              subtitle: l10n.security_loginNotificationsSubtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSecurityAlertOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.devices,
              title: l10n.security_newDeviceAlerts,
              subtitle: l10n.security_newDeviceAlertsSubtitle,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Session Management
            AppText(
              l10n.security_sessions.toUpperCase(),
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSecurityOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.devices,
              title: l10n.security_devices,
              subtitle: l10n.security_devicesSubtitle,
              onTap: () => context.fsmPush('/settings/devices'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSecurityOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.smartphone,
              title: l10n.security_activeSessions,
              subtitle: l10n.security_activeSessionsSubtitle,
              onTap: () => context.fsmPush('/settings/sessions'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSecurityOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.logout,
              title: l10n.security_logoutAllDevices,
              subtitle: l10n.security_logoutAllDevicesSubtitle,
              onTap: () => _confirmLogoutAll(),
              isDanger: true,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Privacy
            AppText(
              l10n.security_privacy.toUpperCase(),
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildToggleOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.screenshot_rounded,
              title: l10n.security_screenshotProtection,
              subtitle: l10n.security_screenshotProtectionSubtitle,
              value: settings.screenshotProtection,
              onChanged: settingsNotifier.setScreenshotProtection,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSecurityOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.history,
              title: l10n.security_loginHistory,
              subtitle: l10n.security_loginHistorySubtitle,
              onTap: () => _showLoginHistory(),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSecurityOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.delete_forever,
              title: l10n.security_deleteAccount,
              subtitle: l10n.security_deleteAccountSubtitle,
              onTap: () => context.fsmPush('/settings/delete-account'),
              isDanger: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityScoreCard(ThemeColors colors) {
    final l10n = AppLocalizations.of(context)!;
    final score = _calculateSecurityScore();
    final scoreColor = score >= 80
        ? context.colors.success
        : (score >= 60 ? context.colors.warning : context.colors.error);

    return AppCard(
      variant: AppCardVariant.goldAccent,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: colors.textSecondary.withValues(
                          alpha: 0.2,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      ),
                    ),
                    AppText(
                      '$score',
                      variant: AppTextVariant.headlineSmall,
                      color: scoreColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.security_scoreTitle,
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      _getScoreDescription(score, l10n),
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (score < 100) ...[
            const SizedBox(height: AppSpacing.lg),
            Divider(color: colors.textSecondary.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: colors.gold, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppText(
                    _getScoreTip(score, l10n),
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityOption({
    required AppLocalizations l10n,
    required ThemeColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.flat,
        borderRadius: AppRadius.lg,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDanger
                    ? context.colors.error.withValues(alpha: 0.1)
                    : colors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: isDanger ? context.colors.errorText : colors.gold,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.labelMedium,
                    color: isDanger
                        ? context.colors.errorText
                        : colors.textPrimary,
                  ),
                  AppText(
                    subtitle,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDanger ? context.colors.errorText : colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required AppLocalizations l10n,
    required ThemeColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.flat,
        borderRadius: AppRadius.lg,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: colors.gold, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    subtitle,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: AppText(
                status,
                variant: AppTextVariant.labelSmall,
                color: colors.gold,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right, color: colors.textTertiary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required AppLocalizations l10n,
    required ThemeColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.flat,
        borderRadius: AppRadius.lg,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: colors.gold, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    subtitle,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Switch.adaptive(
              value: value,
              activeThumbColor: colors.gold,
              activeTrackColor: colors.gold.withValues(alpha: 0.28),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityAlertOption({
    required AppLocalizations l10n,
    required ThemeColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final prefsState = ref.watch(notificationPreferencesProvider);
    final prefs = prefsState.preferences;
    final enabled = prefs?.smsSecurity == true || prefs?.pushSecurity == true;
    final status = prefsState.isLoading
        ? l10n.security_loading
        : (enabled ? l10n.notifications_required : l10n.settings_preferences);

    return _buildStatusOption(
      l10n: l10n,
      colors: colors,
      icon: icon,
      title: title,
      subtitle: prefsState.error == null
          ? subtitle
          : l10n.notifications_loadError,
      status: status,
      onTap: () => context.fsmPush('/settings/notifications'),
    );
  }

  Widget _buildTransactionAlertOption({
    required AppLocalizations l10n,
    required ThemeColors colors,
  }) {
    final prefsState = ref.watch(notificationPreferencesProvider);
    final prefs = prefsState.preferences;
    final enabled =
        (prefs?.pushTransactions ?? false) ||
        (prefs?.smsTransactions ?? false) ||
        (prefs?.emailTransactions ?? false);
    final status = prefsState.isLoading
        ? l10n.security_loading
        : (enabled
              ? l10n.biometric_settings_status_enabled
              : l10n.settings_preferences);

    return _buildStatusOption(
      l10n: l10n,
      colors: colors,
      icon: Icons.notifications_active_rounded,
      title: l10n.security_transactionAlerts,
      subtitle: prefsState.error == null
          ? l10n.security_transactionAlertsSubtitle
          : l10n.notifications_loadError,
      status: status,
      onTap: () => context.fsmPush('/settings/notifications'),
    );
  }

  void _showAutoLockPicker(AppLocalizations l10n) {
    final colors = context.colors;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.security_autoLockAfter,
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final minutes in const [1, 2, 5, 10, 15, 30])
                  _buildAutoLockOption(
                    colors: colors,
                    label: l10n.security_minutesFormat(minutes),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await ref
                          .read(securitySettingsProvider.notifier)
                          .setAutoLock(minutes);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAutoLockOption({
    required ThemeColors colors,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.flat,
        borderRadius: AppRadius.md,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        onTap: onTap,
        child: Row(
          children: [
            Icon(Icons.timer_outlined, color: colors.gold, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(
                label,
                variant: AppTextVariant.labelMedium,
                color: colors.textPrimary,
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSubscriptionOption({
    required ThemeColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required String actionLabel,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.flat,
        borderRadius: AppRadius.lg,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        onTap: isLoading ? null : onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.border),
              ),
              child: Icon(icon, color: colors.gold, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          title,
                          variant: AppTextVariant.labelMedium,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: AppText(
                          status,
                          variant: AppTextVariant.labelSmall,
                          color: colors.gold,
                        ),
                      ),
                    ],
                  ),
                  AppText(
                    subtitle,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
                      ),
                    )
                  : Semantics(
                      key: const ValueKey('notify'),
                      button: true,
                      label: actionLabel,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.gold.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: colors.gold.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_active_outlined,
                              size: 16,
                              color: colors.gold,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            AppText(
                              actionLabel,
                              variant: AppTextVariant.labelSmall,
                              color: colors.gold,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _subscribeToTwoFactor(AppLocalizations l10n) async {
    if (_isSubscribingToTwoFactor) {
      return;
    }
    setState(() => _isSubscribingToTwoFactor = true);

    final authState = ref.read(authProvider);
    final user = authState.user;
    final locale =
        user?.preferredLocale ?? Localizations.localeOf(context).languageCode;

    try {
      await ref
          .read(featureSubscriptionServiceProvider)
          .subscribe(
            FeatureSubscriptionRequest(
              featureKey: 'two_factor_auth',
              source: 'settings_security',
              phone: user?.phone ?? authState.phone,
              email: user?.email,
              featureName: 'Authenticator app 2FA',
              requestedFeature: 'backend_enforced_mfa',
              countryCode: user?.countryCode,
              locale: locale,
              metadata: const {
                'surface': 'settings_security',
                'currentProtections': [
                  'transaction_pin',
                  'device_biometrics_optional',
                ],
                'requiresBackendEnforcement': true,
              },
            ),
          );

      _showSecuritySnack(
        l10n.security_twoFactorNotifySuccess,
        tone: AppSnackTone.success,
      );
    } on Object catch (e) {
      _showSecuritySnack(
        l10n.common_errorFormat(e.toString()),
        tone: AppSnackTone.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubscribingToTwoFactor = false);
      }
    }
  }

  void _showSecuritySnack(String message, {required AppSnackTone tone}) {
    if (!mounted) {
      return;
    }
    context.showSnack(message, tone: tone);
  }

  Widget _buildBiometricOption(AppLocalizations l10n, ThemeColors colors) {
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return biometricEnabled.when(
      data: (enabled) => _buildSecurityOption(
        l10n: l10n,
        colors: colors,
        icon: Icons.fingerprint,
        title: l10n.security_biometricLogin,
        subtitle: enabled
            ? l10n.biometric_settings_enabled_subtitle
            : l10n.biometric_settings_disabled_subtitle,
        onTap: () => context.fsmPush('/settings/biometric'),
      ),
      loading: () => _buildSecurityOption(
        l10n: l10n,
        colors: colors,
        icon: Icons.fingerprint,
        title: l10n.security_biometricLogin,
        subtitle: l10n.security_loading,
        onTap: () => context.fsmPush('/settings/biometric'),
      ),
      error: (_, __) => _buildSecurityOption(
        l10n: l10n,
        colors: colors,
        icon: Icons.fingerprint,
        title: l10n.security_biometricLogin,
        subtitle: l10n.security_errorLoadingState,
        onTap: () => context.fsmPush('/settings/biometric'),
      ),
    );
  }

  int _calculateSecurityScore() {
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final biometricsOn = biometricEnabled.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    int score = 55; // Account, device, session, and backend risk controls.
    score += 25; // Transaction PIN is mandatory for money movement.
    final prefsState = ref.watch(notificationPreferencesProvider);
    final prefs = prefsState.preferences;
    if (biometricsOn) score += 10;
    if (prefs?.smsSecurity == true || prefs?.pushSecurity == true) score += 10;
    return score.clamp(0, 100);
  }

  String _getScoreDescription(int score, AppLocalizations l10n) {
    if (score >= 90) return l10n.security_scoreExcellent;
    if (score >= 70) return l10n.security_scoreGood;
    if (score >= 50) return l10n.security_scoreModerate;
    return l10n.security_scoreLow;
  }

  String _getScoreTip(int score, AppLocalizations l10n) {
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final biometricsOn = biometricEnabled.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    if (!biometricsOn) return l10n.security_tipEnableBiometrics;
    final prefsState = ref.watch(notificationPreferencesProvider);
    final prefs = prefsState.preferences;
    final securityAlertsOn =
        prefs?.smsSecurity == true || prefs?.pushSecurity == true;

    if (!securityAlertsOn) return l10n.security_tipEnableNotifications;
    return l10n.security_twoFactorComingSoonSubtitle;
  }

  void _confirmLogoutAll() {
    final l10n = AppLocalizations.of(context)!;
    // ignore: unused_local_variable
    final __colors = context.colors;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: dialogColors.container,
          title: AppText(
            l10n.security_logoutAllTitle,
            variant: AppTextVariant.titleMedium,
            color: dialogColors.textPrimary,
          ),
          content: AppText(
            l10n.security_logoutAllMessage,
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
              label: l10n.security_logoutAll,
              onPressed: () async {
                Navigator.pop(dialogContext);
                final success = await ref
                    .read(sessionsProvider.notifier)
                    .logoutAllDevices();
                if (!mounted || !context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? l10n.security_logoutAllSuccess
                          : 'Erreur lors de la déconnexion',
                    ),
                    backgroundColor: success
                        ? context.colors.success
                        : context.colors.error,
                  ),
                );
                if (success) {
                  context.fsmGo('/login');
                }
              },
              variant: AppButtonVariant.danger,
              size: AppButtonSize.small,
            ),
          ],
        );
      },
    );
  }

  void _showLoginHistory() {
    final l10n = AppLocalizations.of(context)!;

    // Trigger loading sessions
    ref.read(sessionsProvider.notifier).loadSessions();

    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Consumer(
            builder: (context, ref, _) {
              final sessionsState = ref.watch(sessionsProvider);
              final colors = context.colors;

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.security_loginHistoryTitle,
                      variant: AppTextVariant.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (sessionsState.isLoading)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (sessionsState.error != null)
                      Expanded(
                        child: Center(
                          child: AppText(
                            l10n.security_errorLoadingState,
                            variant: AppTextVariant.bodyMedium,
                            color: colors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (sessionsState.sessions.isEmpty)
                      Expanded(
                        child: Center(
                          child: AppText(
                            'Aucun historique de connexion disponible.',
                            variant: AppTextVariant.bodyMedium,
                            color: colors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: sessionsState.sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessionsState.sessions[index];
                            return _buildLoginHistoryItem(
                              l10n: l10n,
                              colors: colors,
                              device: session.deviceDescription,
                              location:
                                  session.location ??
                                  session.ipAddress ??
                                  'Inconnu',
                              time: _formatSessionTime(session.lastActivityAt),
                              success: session.isActive,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatSessionTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Il y a ${difference.inHours}h';
    if (difference.inDays < 7) return 'Il y a ${difference.inDays}j';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Widget _buildLoginHistoryItem({
    required AppLocalizations l10n,
    required ThemeColors colors,
    required String time,
    required String device,
    required String location,
    required bool success,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: success
                    ? context.colors.success.withValues(alpha: 0.1)
                    : context.colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check : Icons.close,
                color: success ? context.colors.success : context.colors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(device, variant: AppTextVariant.labelMedium),
                  AppText(
                    '$location - $time',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            AppText(
              success ? l10n.security_loginSuccess : l10n.security_loginFailed,
              variant: AppTextVariant.labelSmall,
              color: success ? context.colors.success : context.colors.error,
            ),
          ],
        ),
      ),
    );
  }
}
