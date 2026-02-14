import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class SecurityView extends ConsumerStatefulWidget {
  const SecurityView({super.key});

  @override
  ConsumerState<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends ConsumerState<SecurityView> {
  bool _twoFactorEnabled = false;
  bool _transactionPinRequired = true;
  bool _loginNotifications = true;
  bool _newDeviceAlerts = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

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
          onPressed: () => context.safePop(fallbackRoute: '/settings'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Score
            _buildSecurityScoreCard(colors),

            const SizedBox(height: AppSpacing.xxl),

            // Authentication Section
            AppText(
              l10n.security_authentication,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSecurityOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.lock_outline,
              title: l10n.security_changePin,
              subtitle: l10n.security_changePinSubtitle,
              onTap: () => context.push('/settings/pin'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildBiometricOption(l10n, colors),
            const SizedBox(height: AppSpacing.sm),
            _buildToggleOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.security,
              title: l10n.security_twoFactorAuth,
              subtitle: _twoFactorEnabled ? l10n.security_twoFactorEnabledSubtitle : l10n.security_twoFactorDisabledSubtitle,
              value: _twoFactorEnabled,
              onChanged: (value) => _handleTwoFactorToggle(value),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Transaction Security
            AppText(
              l10n.security_transactionSecurity,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildToggleOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.pin,
              title: l10n.security_requirePinForTransactions,
              subtitle: l10n.security_requirePinSubtitle,
              value: _transactionPinRequired,
              onChanged: (value) => setState(() => _transactionPinRequired = value),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Alerts Section
            AppText(
              l10n.security_alerts,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildToggleOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.login,
              title: l10n.security_loginNotifications,
              subtitle: l10n.security_loginNotificationsSubtitle,
              value: _loginNotifications,
              onChanged: (value) => setState(() => _loginNotifications = value),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildToggleOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.devices,
              title: l10n.security_newDeviceAlerts,
              subtitle: l10n.security_newDeviceAlertsSubtitle,
              value: _newDeviceAlerts,
              onChanged: (value) => setState(() => _newDeviceAlerts = value),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Session Management
            AppText(
              l10n.security_sessions,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSecurityOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.devices,
              title: l10n.security_devices,
              subtitle: l10n.security_devicesSubtitle,
              onTap: () => context.push('/settings/devices'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSecurityOption(
              l10n: l10n,
              colors: colors,
              icon: Icons.smartphone,
              title: l10n.security_activeSessions,
              subtitle: l10n.security_activeSessionsSubtitle,
              onTap: () => context.push('/settings/sessions'),
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
              l10n.security_privacy,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
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
              onTap: () => _confirmDeleteAccount(),
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
      variant: AppCardVariant.elevated,
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
                        backgroundColor: colors.textSecondary.withValues(alpha: 0.2),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDanger
                    ? context.colors.error.withValues(alpha: 0.1)
                    : colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: isDanger ? context.colors.error : colors.gold,
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
                    color: isDanger ? context.colors.error : colors.textPrimary,
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
              color: isDanger ? context.colors.error : colors.textTertiary,
            ),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: AppToggleTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        value: value,
        onChanged: onChanged,
      ),
    );
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
        onTap: () => context.push('/settings/biometric'),
      ),
      loading: () => _buildSecurityOption(
        l10n: l10n,
        colors: colors,
        icon: Icons.fingerprint,
        title: l10n.security_biometricLogin,
        subtitle: l10n.security_loading,
        onTap: () => context.push('/settings/biometric'),
      ),
      error: (_, __) => _buildSecurityOption(
        l10n: l10n,
        colors: colors,
        icon: Icons.fingerprint,
        title: l10n.security_biometricLogin,
        subtitle: l10n.security_errorLoadingState,
        onTap: () => context.push('/settings/biometric'),
      ),
    );
  }

  int _calculateSecurityScore() {
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final biometricsOn = biometricEnabled.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    int score = 40; // Base score for having account
    if (biometricsOn) score += 20;
    if (_twoFactorEnabled) score += 25;
    if (_transactionPinRequired) score += 10;
    if (_loginNotifications) score += 5;
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

    if (!_twoFactorEnabled) return l10n.security_tipEnable2FA;
    if (!biometricsOn) return l10n.security_tipEnableBiometrics;
    if (!_transactionPinRequired) return l10n.security_tipRequirePin;
    return l10n.security_tipEnableNotifications;
  }

  void _handleTwoFactorToggle(bool value) {
    if (value) {
      _showTwoFactorSetup();
    } else {
      _confirmDisableTwoFactor();
    }
  }

  void _showTwoFactorSetup() {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        final sheetColors = context.colors;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: sheetColors.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.security, color: sheetColors.gold, size: 40),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppText(
                l10n.security_setup2FATitle,
                variant: AppTextVariant.titleMedium,
                color: sheetColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                l10n.security_setup2FAMessage,
                variant: AppTextVariant.bodyMedium,
                color: sheetColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.security_continueSetup,
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _twoFactorEnabled = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.security_2FAEnabledSuccess),
                      backgroundColor: context.colors.success,
                    ),
                  );
                },
                variant: AppButtonVariant.primary,
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.action_cancel,
                onPressed: () => Navigator.pop(context),
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDisableTwoFactor() {
    final l10n = AppLocalizations.of(context)!;
    final _colors = context.colors;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: dialogColors.container,
          title: AppText(
            l10n.security_disable2FATitle,
            variant: AppTextVariant.titleMedium,
            color: dialogColors.textPrimary,
          ),
          content: AppText(
            l10n.security_disable2FAMessage,
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
              label: l10n.security_disable,
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() => _twoFactorEnabled = false);
              },
              variant: AppButtonVariant.danger,
              size: AppButtonSize.small,
            ),
          ],
        );
      },
    );
  }


  void _confirmLogoutAll() {
    final l10n = AppLocalizations.of(context)!;
    final _colors = context.colors;

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
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.security_logoutAllSuccess),
                    backgroundColor: context.colors.success,
                  ),
                );
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

    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final colors = context.colors;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.security_loginHistoryTitle,
                  variant: AppTextVariant.titleMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildLoginHistoryItem(
                        l10n: l10n,
                        colors: colors,
                        time: 'Today, 10:30 AM',
                        device: 'iPhone 15 Pro',
                        location: 'San Francisco, CA',
                        success: true,
                      ),
                      _buildLoginHistoryItem(
                        l10n: l10n,
                        colors: colors,
                        time: 'Yesterday, 3:45 PM',
                        device: 'MacBook Pro',
                        location: 'San Francisco, CA',
                        success: true,
                      ),
                      _buildLoginHistoryItem(
                        l10n: l10n,
                        colors: colors,
                        time: 'Yesterday, 9:12 AM',
                        device: 'Unknown Device',
                        location: 'New York, NY',
                        success: false,
                      ),
                      _buildLoginHistoryItem(
                        l10n: l10n,
                        colors: colors,
                        time: 'Jan 20, 2:30 PM',
                        device: 'iPhone 15 Pro',
                        location: 'Los Angeles, CA',
                        success: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  AppText(
                    device,
                    variant: AppTextVariant.labelMedium,
                  ),
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

  void _confirmDeleteAccount() {
    final l10n = AppLocalizations.of(context)!;
    final _colors = context.colors;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.colors;
        return AlertDialog(
          backgroundColor: dialogColors.container,
          title: AppText(
            l10n.security_deleteAccountTitle,
            variant: AppTextVariant.titleMedium,
            color: context.colors.error,
          ),
          content: AppText(
            l10n.security_deleteAccountMessage,
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
              label: l10n.security_delete,
              onPressed: () {
                Navigator.pop(dialogContext);
                // Would show another confirmation
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
