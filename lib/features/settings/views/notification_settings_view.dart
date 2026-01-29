import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/entities/notification_preferences.dart';
import '../providers/notification_preferences_provider.dart';

class NotificationSettingsView extends ConsumerStatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  ConsumerState<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState
    extends ConsumerState<NotificationSettingsView> {
  // Local state for immediate UI feedback
  UserNotificationPreferences? _localPrefs;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final prefsState = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Notification Settings',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => _handleBack(),
        ),
      ),
      body: _buildBody(prefsState),
    );
  }

  Widget _buildBody(NotificationPreferencesState state) {
    final colors = context.colors;
    // Show loading state
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.gold),
      );
    }

    // Show error state
    if (state.error != null && state.preferences == null) {
      return _buildErrorState(state.error!, colors);
    }

    // Initialize local state from loaded preferences
    if (_localPrefs == null && state.preferences != null) {
      _localPrefs = state.preferences;
    }

    if (state.preferences == null) {
      return _buildErrorState('Failed to load preferences', colors);
    }

    final prefs = _localPrefs ?? state.preferences!;
    final isSaving = state.isSaving || _isSaving;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Push Notifications Section
              _buildSectionHeader(
                colors: colors,
                icon: Icons.notifications,
                title: 'Push Notifications',
                enabled: prefs.pushEnabled,
                onChanged: (value) => _updateLocalState(
                  prefs.copyWith(
                    pushEnabled: value,
                    pushTransactions: value ? prefs.pushTransactions : false,
                    pushSecurity: value ? prefs.pushSecurity : false,
                    pushMarketing: value ? prefs.pushMarketing : false,
                  ),
                ),
              ),
              if (prefs.pushEnabled) ...[
                _buildSettingTile(
                  colors: colors,
                  title: 'Transaction Alerts',
                  subtitle:
                      'Get notified for deposits, transfers, and withdrawals',
                  value: prefs.pushTransactions,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(pushTransactions: value),
                  ),
                ),
                _buildSettingTile(
                  colors: colors,
                  title: 'Security Alerts',
                  subtitle: 'Login attempts and account changes',
                  value: prefs.pushSecurity,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(pushSecurity: value),
                  ),
                ),
                _buildSettingTile(
                  colors: colors,
                  title: 'Promotions & Updates',
                  subtitle: 'Special offers and new features',
                  value: prefs.pushMarketing,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(pushMarketing: value),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Email Notifications Section
              _buildSectionHeader(
                colors: colors,
                icon: Icons.email,
                title: 'Email Notifications',
                enabled: prefs.emailEnabled,
                onChanged: (value) => _updateLocalState(
                  prefs.copyWith(
                    emailEnabled: value,
                    emailTransactions:
                        value ? prefs.emailTransactions : false,
                    emailMonthlyStatement:
                        value ? prefs.emailMonthlyStatement : false,
                    emailMarketing: value ? prefs.emailMarketing : false,
                  ),
                ),
              ),
              if (prefs.emailEnabled) ...[
                _buildSettingTile(
                  colors: colors,
                  title: 'Transaction Receipts',
                  subtitle: 'Receive email receipts for transactions',
                  value: prefs.emailTransactions,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(emailTransactions: value),
                  ),
                ),
                _buildSettingTile(
                  colors: colors,
                  title: 'Monthly Statements',
                  subtitle: 'Get a monthly summary of your account',
                  value: prefs.emailMonthlyStatement,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(emailMonthlyStatement: value),
                  ),
                ),
                _buildSettingTile(
                  colors: colors,
                  title: 'Promotions & Newsletter',
                  subtitle: 'Product updates and special offers',
                  value: prefs.emailMarketing,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(emailMarketing: value),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // SMS Notifications Section
              _buildSectionHeader(
                colors: colors,
                icon: Icons.sms,
                title: 'SMS Notifications',
                enabled: prefs.smsEnabled,
                onChanged: (value) => _updateLocalState(
                  prefs.copyWith(
                    smsEnabled: value,
                    smsTransactions: value ? prefs.smsTransactions : false,
                    // smsSecurity stays true - cannot be disabled
                  ),
                ),
              ),
              if (prefs.smsEnabled) ...[
                _buildSettingTile(
                  colors: colors,
                  title: 'Transaction Alerts',
                  subtitle: 'SMS for large transactions',
                  value: prefs.smsTransactions,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(smsTransactions: value),
                  ),
                ),
                _buildSettingTile(
                  colors: colors,
                  title: 'Security Codes',
                  subtitle: 'OTP and security verification codes',
                  value: prefs.smsSecurity,
                  onChanged: null, // Cannot be changed
                  isRequired: true,
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Info
              AppCard(
                variant: AppCardVariant.subtle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.infoBase, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        'Security SMS notifications cannot be disabled. They are required for account protection.',
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Save Button
              AppButton(
                label: 'Save Preferences',
                onPressed: _hasUnsavedChanges ? _savePreferences : null,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                isLoading: isSaving,
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        // Show saving overlay
        if (isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(String error, ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.errorBase, size: 64),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              'Failed to load preferences',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Try Again',
              onPressed: () {
                ref.read(notificationPreferencesProvider.notifier).refresh();
              },
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required ThemeColors colors,
    required IconData icon,
    required String title,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? colors.gold.withValues(alpha: 0.2)
                  : colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: enabled ? colors.gold : colors.textTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              title,
              variant: AppTextVariant.titleSmall,
              color: colors.textPrimary,
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
            activeTrackColor: colors.gold.withValues(alpha: 0.5),
            activeColor: colors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required ThemeColors colors,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppText(
                      title,
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textPrimary,
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningBase.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: const AppText(
                          'Required',
                          variant: AppTextVariant.labelSmall,
                          color: AppColors.warningBase,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isRequired ? true : value,
            onChanged: isRequired ? null : onChanged,
            activeTrackColor: colors.gold.withValues(alpha: 0.5),
            activeColor: colors.gold,
          ),
        ],
      ),
    );
  }

  void _updateLocalState(UserNotificationPreferences newPrefs) {
    setState(() {
      _localPrefs = newPrefs;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _savePreferences() async {
    if (_localPrefs == null) return;

    setState(() => _isSaving = true);

    try {
      final success = await ref
          .read(notificationPreferencesProvider.notifier)
          .updatePreferences(_localPrefs!);

      if (mounted) {
        if (success) {
          setState(() {
            _hasUnsavedChanges = false;
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification preferences saved'),
              backgroundColor: AppColors.successBase,
            ),
          );
          context.pop();
        } else {
          setState(() => _isSaving = false);
          final state = ref.read(notificationPreferencesProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Failed to save preferences'),
              backgroundColor: AppColors.errorBase,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save preferences: $e'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }

  void _handleBack() {
    if (_hasUnsavedChanges) {
      final colors = context.colors;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colors.elevated,
          title: const AppText(
            'Unsaved Changes',
            variant: AppTextVariant.titleMedium,
          ),
          content: const AppText(
            'You have unsaved changes. Do you want to discard them?',
            variant: AppTextVariant.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text(
                'Discard',
                style: TextStyle(color: AppColors.errorBase),
              ),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }
}
