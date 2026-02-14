import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/entities/notification_preferences.dart';
import 'package:usdc_wallet/features/settings/providers/notification_preferences_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final prefsState = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.settings_notifications,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => _handleBack(l10n),
        ),
      ),
      body: _buildBody(prefsState, l10n, colors),
    );
  }

  Widget _buildBody(NotificationPreferencesState state, AppLocalizations l10n, ThemeColors colors) {
    // Show loading state
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.gold),
      );
    }

    // Show error state
    if (state.error != null && state.preferences == null) {
      return _buildErrorState(state.error!, l10n, colors);
    }

    // Initialize local state from loaded preferences
    if (_localPrefs == null && state.preferences != null) {
      _localPrefs = state.preferences;
    }

    if (state.preferences == null) {
      return _buildErrorState(l10n.notifications_loadError, l10n, colors);
    }

    final prefs = _localPrefs ?? state.preferences!;
    final isSaving = state.isSaving || _isSaving;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Push Notifications Section
              _buildSectionHeader(
                l10n: l10n,
                colors: colors,
                icon: Icons.notifications,
                title: l10n.notifications_push,
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
                  l10n: l10n,
                  colors: colors,
                  title: l10n.notifications_transactions,
                  subtitle: l10n.notifications_transactionsDescription,
                  value: prefs.pushTransactions,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(pushTransactions: value),
                  ),
                ),
                _buildSettingTile(
                  l10n: l10n,
                  colors: colors,
                  title: l10n.notifications_security,
                  subtitle: l10n.notifications_securityDescription,
                  value: prefs.pushSecurity,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(pushSecurity: value),
                  ),
                ),
                _buildSettingTile(
                  l10n: l10n,
                  colors: colors,
                  title: l10n.notifications_marketing,
                  subtitle: l10n.notifications_marketingDescription,
                  value: prefs.pushMarketing,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(pushMarketing: value),
                  ),
                ),
              ],

              SizedBox(height: AppSpacing.xxl),

              // Email Notifications Section
              _buildSectionHeader(
                l10n: l10n,
                colors: colors,
                icon: Icons.email,
                title: l10n.notifications_email,
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
                  l10n: l10n,
                  colors: colors,
                  title: l10n.notifications_emailReceipts,
                  subtitle: l10n.notifications_emailReceiptsDescription,
                  value: prefs.emailTransactions,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(emailTransactions: value),
                  ),
                ),
                _buildSettingTile(
                  l10n: l10n,
                  colors: colors,
                  title: l10n.notifications_monthlyStatement,
                  subtitle: l10n.notifications_monthlyStatementDescription,
                  value: prefs.emailMonthlyStatement,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(emailMonthlyStatement: value),
                  ),
                ),
                _buildSettingTile(
                  l10n: l10n,
                  colors: colors,
                  title: l10n.notifications_newsletter,
                  subtitle: l10n.notifications_newsletterDescription,
                  value: prefs.emailMarketing,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(emailMarketing: value),
                  ),
                ),
              ],

              SizedBox(height: AppSpacing.xxl),

              // SMS Notifications Section
              _buildSectionHeader(
                l10n: l10n,
                colors: colors,
                icon: Icons.sms,
                title: l10n.notifications_sms,
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
                  l10n: l10n,
                  colors: colors,
                  title: l10n.notifications_smsTransactions,
                  subtitle: l10n.notifications_smsTransactionsDescription,
                  value: prefs.smsTransactions,
                  onChanged: (value) => _updateLocalState(
                    prefs.copyWith(smsTransactions: value),
                  ),
                ),
                _buildSettingTile(
                  l10n: l10n,
                  colors: colors,
                  title: l10n.notifications_securityCodes,
                  subtitle: l10n.notifications_securityCodesDescription,
                  value: prefs.smsSecurity,
                  onChanged: null, // Cannot be changed
                  isRequired: true,
                ),
              ],

              SizedBox(height: AppSpacing.xxl),

              // Info
              AppCard(
                variant: AppCardVariant.subtle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: context.colors.info, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        l10n.notifications_securityNote,
                        variant: AppTextVariant.bodySmall,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.xxxl),

              // Save Button
              AppButton(
                label: l10n.notifications_savePreferences,
                onPressed: _hasUnsavedChanges ? _savePreferences : null,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                isLoading: isSaving,
              ),

              SizedBox(height: AppSpacing.lg),
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

  Widget _buildErrorState(String error, AppLocalizations l10n, ThemeColors colors) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: context.colors.error, size: 64),
            SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.notifications_errorTitle,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.action_retry,
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
    required AppLocalizations l10n,
    required ThemeColors colors,
    required IconData icon,
    required String title,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? colors.gold.withOpacity(0.2)
                  : colors.container,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: enabled ? colors.gold : colors.textTertiary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              title,
              variant: AppTextVariant.titleSmall,
              color: colors.textPrimary,
            ),
          ),
          AppToggle(
            value: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required AppLocalizations l10n,
    required ThemeColors colors,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool isRequired = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.container,
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
                      SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: AppText(
                          l10n.notifications_required,
                          variant: AppTextVariant.labelSmall,
                          color: context.colors.warning,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: AppSpacing.xxs),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          AppToggle(
            value: isRequired ? true : value,
            onChanged: isRequired ? null : onChanged,
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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(l10n.notifications_saveSuccess),
              backgroundColor: context.colors.success,
            ),
          );
          context.safePop(fallbackRoute: '/settings');
        } else {
          setState(() => _isSaving = false);
          final l10n = AppLocalizations.of(context)!;
          final state = ref.read(notificationPreferencesProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AppText(state.error ?? l10n.notifications_saveError),
              backgroundColor: context.colors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(l10n.notifications_saveError),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  void _handleBack(AppLocalizations l10n) {
    if (_hasUnsavedChanges) {
      final colors = context.colors;
      showDialog(
        context: context,
        builder: (dialogContext) {
          final dialogColors = dialogContext.colors;
          return AlertDialog(
            backgroundColor: dialogColors.container,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            title: AppText(
              l10n.notifications_unsavedChanges,
              variant: AppTextVariant.titleMedium,
              color: dialogColors.textPrimary,
            ),
            content: AppText(
              l10n.notifications_unsavedChangesMessage,
              variant: AppTextVariant.bodyMedium,
              color: dialogColors.textSecondary,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: AppText(
                  l10n.action_cancel,
                  color: dialogColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.safePop(fallbackRoute: '/settings');
                },
                child: AppText(
                  l10n.action_discard,
                  color: context.colors.error,
                ),
              ),
            ],
          );
        },
      );
    } else {
      context.safePop(fallbackRoute: '/settings');
    }
  }
}
