// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/features/biometric/providers/biometric_settings_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Biometric Settings View
/// Manage biometric authentication preferences
class BiometricSettingsView extends ConsumerStatefulWidget {
  const BiometricSettingsView({super.key});

  @override
  ConsumerState<BiometricSettingsView> createState() =>
      _BiometricSettingsViewState();
}

class _BiometricSettingsViewState extends ConsumerState<BiometricSettingsView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(biometricSettingsProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.biometric_settings_title,
          variant: AppTextVariant.titleLarge,
          color: context.colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(l10n),
            const SizedBox(height: AppSpacing.xxl),

            // Main Toggle
            AppText(
              l10n.biometric_settings_authentication,
              variant: AppTextVariant.titleMedium,
              color: context.colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBiometricToggle(l10n),
            const SizedBox(height: AppSpacing.xxl),

            // Use Cases
            if (settings.isBiometricEnabled) ...[
              AppText(
                l10n.biometric_settings_use_cases,
                variant: AppTextVariant.titleMedium,
                color: context.colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildUseCaseToggle(
                l10n: l10n,
                icon: Icons.lock_open,
                title: l10n.biometric_settings_app_unlock_title,
                subtitle: l10n.biometric_settings_app_unlock_subtitle,
                value: settings.requireForAppUnlock,
                onChanged: (value) => ref
                    .read(biometricSettingsProvider.notifier)
                    .setRequireForAppUnlock(value),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildUseCaseToggle(
                l10n: l10n,
                icon: Icons.send,
                title: l10n.biometric_settings_transactions_title,
                subtitle: l10n.biometric_settings_transactions_subtitle,
                value: settings.requireForTransactions,
                onChanged: (value) => ref
                    .read(biometricSettingsProvider.notifier)
                    .setRequireForTransactions(value),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildUseCaseToggle(
                l10n: l10n,
                icon: Icons.settings,
                title: l10n.biometric_settings_sensitive_title,
                subtitle: l10n.biometric_settings_sensitive_subtitle,
                value: settings.requireForSensitiveSettings,
                onChanged: (value) => ref
                    .read(biometricSettingsProvider.notifier)
                    .setRequireForSensitiveSettings(value),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildUseCaseToggle(
                l10n: l10n,
                icon: Icons.visibility,
                title: l10n.biometric_settings_view_balance_title,
                subtitle: l10n.biometric_settings_view_balance_subtitle,
                value: settings.requireForViewBalance,
                onChanged: (value) => ref
                    .read(biometricSettingsProvider.notifier)
                    .setRequireForViewBalance(value),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Advanced Settings
              AppText(
                l10n.biometric_settings_advanced,
                variant: AppTextVariant.titleMedium,
                color: context.colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTimeoutSelector(l10n, settings),
              const SizedBox(height: AppSpacing.sm),
              _buildHighValueThreshold(l10n, settings),
              const SizedBox(height: AppSpacing.xxl),

              // Actions
              AppText(
                l10n.biometric_settings_actions,
                variant: AppTextVariant.titleMedium,
                color: context.colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildReEnrollButton(l10n),
              const SizedBox(height: AppSpacing.sm),
              _buildFallbackToPinButton(l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n) {
    final biometricType = ref.watch(primaryBiometricTypeProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return biometricType.when(
      data: (type) => biometricEnabled.when(
        data: (enabled) {
          final typeName = _getBiometricTypeName(type ?? BiometricType.none, l10n);
          final statusColor = enabled ? context.colors.success : context.colors.textSecondary;

          return AppCard(
            variant: AppCardVariant.elevated,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getBiometricIcon(type ?? BiometricType.none),
                    color: statusColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        typeName,
                        variant: AppTextVariant.titleMedium,
                        color: context.colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        enabled
                            ? l10n.biometric_settings_status_enabled
                            : l10n.biometric_settings_status_disabled,
                        variant: AppTextVariant.bodySmall,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: AppText(
                    enabled
                        ? l10n.biometric_settings_active
                        : l10n.biometric_settings_inactive,
                    variant: AppTextVariant.labelSmall,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => _buildLoadingCard(),
        error: (_, __) => _buildErrorCard(l10n),
      ),
      loading: () => _buildLoadingCard(),
      error: (_, __) => _buildErrorCard(l10n),
    );
  }

  Widget _buildLoadingCard() {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Row(
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.colors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: context.colors.error,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: AppText(
              l10n.biometric_settings_error_loading,
              variant: AppTextVariant.bodyMedium,
              color: context.colors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricToggle(AppLocalizations l10n) {
    final biometricAvailable = ref.watch(biometricAvailableProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return biometricAvailable.when(
      data: (available) {
        if (!available) {
          return _buildOptionCard(
            l10n: l10n,
            icon: Icons.fingerprint,
            title: l10n.security_biometricLogin,
            subtitle: l10n.security_biometricNotAvailable,
            trailing: AppText(
              l10n.biometric_settings_unavailable,
              variant: AppTextVariant.labelSmall,
              color: context.colors.warning,
            ),
          );
        }

        return biometricEnabled.when(
          data: (enabled) => _buildToggleCard(
            l10n: l10n,
            icon: Icons.fingerprint,
            title: l10n.security_biometricLogin,
            subtitle: enabled
                ? l10n.biometric_settings_enabled_subtitle
                : l10n.biometric_settings_disabled_subtitle,
            value: enabled,
            onChanged: (value) => _handleBiometricToggle(value, l10n),
          ),
          loading: () => _buildLoadingToggle(l10n),
          error: (_, __) => _buildErrorToggle(l10n),
        );
      },
      loading: () => _buildLoadingToggle(l10n),
      error: (_, __) => _buildErrorToggle(l10n),
    );
  }

  Widget _buildUseCaseToggle({
    required AppLocalizations l10n,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildToggleCard(
      l10n: l10n,
      icon: icon,
      title: title,
      subtitle: subtitle,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildToggleCard({
    required AppLocalizations l10n,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: context.colors.gold, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelMedium,
                  color: context.colors.textPrimary,
                ),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.colors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required AppLocalizations l10n,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: context.colors.textSecondary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelMedium,
                  color: context.colors.textPrimary,
                ),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLoadingToggle(AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              l10n.security_loading,
              variant: AppTextVariant.labelMedium,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorToggle(AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.error, color: context.colors.error, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              l10n.security_errorLoadingState,
              variant: AppTextVariant.labelMedium,
              color: context.colors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeoutSelector(AppLocalizations l10n, BiometricSettings settings) {
    return InkWell(
      onTap: () => _showTimeoutSelector(l10n, settings),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.timer, color: context.colors.gold, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.biometric_settings_timeout_title,
                    variant: AppTextVariant.labelMedium,
                    color: context.colors.textPrimary,
                  ),
                  AppText(
                    _getTimeoutDescription(settings.biometricTimeoutMinutes, l10n),
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildHighValueThreshold(AppLocalizations l10n, BiometricSettings settings) {
    return InkWell(
      onTap: () => _showThresholdSelector(l10n, settings),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.attach_money, color: context.colors.gold, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.biometric_settings_high_value_title,
                    variant: AppTextVariant.labelMedium,
                    color: context.colors.textPrimary,
                  ),
                  AppText(
                    l10n.biometric_settings_high_value_subtitle(
                      settings.highValueThreshold.toStringAsFixed(0),
                    ),
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildReEnrollButton(AppLocalizations l10n) {
    return InkWell(
      onTap: () => _handleReEnroll(l10n),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.refresh, color: context.colors.gold, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.biometric_settings_reenroll_title,
                    variant: AppTextVariant.labelMedium,
                    color: context.colors.textPrimary,
                  ),
                  AppText(
                    l10n.biometric_settings_reenroll_subtitle,
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackToPinButton(AppLocalizations l10n) {
    return InkWell(
      onTap: () => context.push('/settings/pin'),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.pin, color: context.colors.gold, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.biometric_settings_fallback_title,
                    variant: AppTextVariant.labelMedium,
                    color: context.colors.textPrimary,
                  ),
                  AppText(
                    l10n.biometric_settings_fallback_subtitle,
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }

  // Helper Methods

  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.faceId:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.visibility;
      case BiometricType.none:
        return Icons.security;
    }
  }

  String _getBiometricTypeName(BiometricType type, AppLocalizations l10n) {
    switch (type) {
      case BiometricType.faceId:
        return l10n.biometric_type_face_id;
      case BiometricType.fingerprint:
        return l10n.biometric_type_fingerprint;
      case BiometricType.iris:
        return l10n.biometric_type_iris;
      case BiometricType.none:
        return l10n.biometric_type_none;
    }
  }

  String _getTimeoutDescription(int minutes, AppLocalizations l10n) {
    if (minutes == 0) {
      return l10n.biometric_settings_timeout_immediate;
    } else if (minutes == 5) {
      return l10n.biometric_settings_timeout_5min;
    } else if (minutes == 15) {
      return l10n.biometric_settings_timeout_15min;
    } else if (minutes == 30) {
      return l10n.biometric_settings_timeout_30min;
    } else {
      return l10n.biometric_settings_timeout_custom(minutes.toString());
    }
  }

  // Event Handlers

  Future<void> _handleBiometricToggle(bool value, AppLocalizations l10n) async {
    if (value) {
      // Navigate to enrollment view
      final result = await context.push<bool>('/settings/biometric/enrollment');
      if (result == true) {
        ref.invalidate(biometricEnabledProvider);
      }
    } else {
      // Confirm disable
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.colors.container,
          title: AppText(
            l10n.biometric_settings_disable_title,
            variant: AppTextVariant.titleMedium,
            color: context.colors.textPrimary,
          ),
          content: AppText(
            l10n.biometric_settings_disable_message,
            variant: AppTextVariant.bodyMedium,
            color: context.colors.textSecondary,
          ),
          actions: [
            AppButton(
              label: l10n.action_cancel,
              onPressed: () => Navigator.pop(context, false),
              variant: AppButtonVariant.ghost,
              size: AppButtonSize.small,
            ),
            AppButton(
              label: l10n.biometric_settings_disable,
              onPressed: () => Navigator.pop(context, true),
              variant: AppButtonVariant.danger,
              size: AppButtonSize.small,
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final biometricService = ref.read(biometricServiceProvider);
        await biometricService.disableBiometric();
        ref.invalidate(biometricEnabledProvider);
      }
    }
  }

  Future<void> _showTimeoutSelector(
    AppLocalizations l10n,
    BiometricSettings settings,
  ) async {
    final timeouts = [0, 5, 15, 30];
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(
          l10n.biometric_settings_timeout_select_title,
          variant: AppTextVariant.titleMedium,
          color: context.colors.textPrimary,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: timeouts.map((timeout) {
            return InkWell(
              onTap: () => Navigator.pop(context, timeout),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Radio<int>(
                      value: timeout,
                      groupValue: settings.biometricTimeoutMinutes,
                      onChanged: (value) => Navigator.pop(context, value),
                      activeColor: context.colors.gold,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        _getTimeoutDescription(timeout, l10n),
                        variant: AppTextVariant.bodyMedium,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      ref
          .read(biometricSettingsProvider.notifier)
          .setBiometricTimeout(selected);
    }
  }

  Future<void> _showThresholdSelector(
    AppLocalizations l10n,
    BiometricSettings settings,
  ) async {
    final thresholds = [100.0, 500.0, 1000.0, 5000.0];
    final selected = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(
          l10n.biometric_settings_threshold_select_title,
          variant: AppTextVariant.titleMedium,
          color: context.colors.textPrimary,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: thresholds.map((threshold) {
            return InkWell(
              onTap: () => Navigator.pop(context, threshold),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Radio<double>(
                      value: threshold,
                      groupValue: settings.highValueThreshold,
                      onChanged: (value) => Navigator.pop(context, value),
                      activeColor: context.colors.gold,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        '\$${threshold.toStringAsFixed(0)}',
                        variant: AppTextVariant.bodyMedium,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      ref
          .read(biometricSettingsProvider.notifier)
          .setHighValueThreshold(selected);
    }
  }

  Future<void> _handleReEnroll(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(
          l10n.biometric_settings_reenroll_confirm_title,
          variant: AppTextVariant.titleMedium,
          color: context.colors.textPrimary,
        ),
        content: AppText(
          l10n.biometric_settings_reenroll_confirm_message,
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
        ),
        actions: [
          AppButton(
            label: l10n.action_cancel,
            onPressed: () => Navigator.pop(context, false),
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.small,
          ),
          AppButton(
            label: l10n.action_continue,
            onPressed: () => Navigator.pop(context, true),
            variant: AppButtonVariant.primary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Disable then re-enable
      final biometricService = ref.read(biometricServiceProvider);
      await biometricService.disableBiometric();
      ref.invalidate(biometricEnabledProvider);

      // Navigate to enrollment
      if (mounted) {
        final result = await context.push<bool>('/settings/biometric/enrollment');
        if (result == true) {
          ref.invalidate(biometricEnabledProvider);
        }
      }
    }
  }
}
