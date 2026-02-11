/// Alert Preferences View
/// Allows users to customize their alert settings
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/alerts/models/index.dart';
import 'package:usdc_wallet/features/alerts/providers/index.dart';

class AlertPreferencesView extends ConsumerStatefulWidget {
  const AlertPreferencesView({super.key});

  @override
  ConsumerState<AlertPreferencesView> createState() => _AlertPreferencesViewState();
}

class _AlertPreferencesViewState extends ConsumerState<AlertPreferencesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alertPreferencesProvider.notifier).loadPreferences();
      ref.read(alertPreferencesProvider.notifier).loadAvailableTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(alertPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          'Alert Preferences',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: state.isSaving ? null : () => _resetToDefault(l10n, colors),
            child: AppText(
              'Reset',
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(color: colors.gold),
            )
          : state.preferences == null
              ? Center(
                  child: AppText(
                    'Failed to load preferences',
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                  ),
                )
              : Stack(
                  children: [
                    _buildContent(state.preferences!, colors, l10n),
                    if (state.isSaving)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: Center(
                          child: CircularProgressIndicator(color: colors.gold),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildContent(AlertPreferences prefs, ThemeColors colors, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Channels Section
          _buildSectionHeader('Notification Channels', colors),
          const SizedBox(height: AppSpacing.md),
          _buildChannelToggle(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive alerts on your device',
            value: prefs.pushAlerts,
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).togglePushAlerts(value),
            colors: colors,
          ),
          _buildChannelToggle(
            icon: Icons.email,
            title: 'Email Alerts',
            subtitle: 'Receive alerts via email',
            value: prefs.emailAlerts,
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).toggleEmailAlerts(value),
            colors: colors,
          ),
          _buildChannelToggle(
            icon: Icons.sms,
            title: 'SMS Alerts',
            subtitle: 'Receive critical alerts via SMS',
            value: prefs.smsAlerts,
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).toggleSmsAlerts(value),
            colors: colors,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Thresholds Section
          _buildSectionHeader('Alert Thresholds', colors),
          const SizedBox(height: AppSpacing.md),
          _buildThresholdSlider(
            title: 'Large Transaction Threshold',
            subtitle: 'Alert when transaction exceeds this amount',
            value: prefs.largeTransactionThreshold,
            min: 100,
            max: 10000,
            suffix: ' USD',
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).setLargeTransactionThreshold(value),
            colors: colors,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildThresholdSlider(
            title: 'Low Balance Alert',
            subtitle: 'Alert when balance drops below this',
            value: prefs.balanceLowThreshold,
            min: 0,
            max: 500,
            suffix: ' USD',
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).setBalanceLowThreshold(value),
            colors: colors,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Alert Types Section
          _buildSectionHeader('Alert Types', colors),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            'Choose which types of alerts you want to receive',
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          ...AlertType.values.map((type) => _buildAlertTypeToggle(prefs, type, colors)),

          const SizedBox(height: AppSpacing.xxl),

          // Quiet Hours Section
          _buildSectionHeader('Quiet Hours', colors),
          const SizedBox(height: AppSpacing.md),
          _buildQuietHoursSection(prefs, colors),

          const SizedBox(height: AppSpacing.xxl),

          // Critical Alerts
          _buildSectionHeader('Critical Alerts', colors),
          const SizedBox(height: AppSpacing.md),
          _buildToggleCard(
            icon: Icons.priority_high,
            title: 'Instant Critical Alerts',
            subtitle: 'Always receive critical alerts immediately, even during quiet hours',
            value: prefs.instantCriticalAlerts,
            onChanged: (value) {
              ref.read(alertPreferencesProvider.notifier).updatePreferences(
                prefs.copyWith(instantCriticalAlerts: value),
              );
            },
            colors: colors,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Digest Frequency
          _buildSectionHeader('Digest Frequency', colors),
          const SizedBox(height: AppSpacing.md),
          _buildDigestFrequencySection(prefs, colors),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeColors colors) {
    return AppText(
      title,
      variant: AppTextVariant.titleMedium,
      color: colors.textPrimary,
    );
  }

  Widget _buildChannelToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeColors colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colors.textSecondary, size: 20),
          ),
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
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.gold, size: 24),
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
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdSlider({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required String suffix,
    required ValueChanged<double> onChanged,
    required ThemeColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                variant: AppTextVariant.bodyLarge,
                color: colors.textPrimary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: AppText(
                  '${value.toStringAsFixed(0)}$suffix',
                  variant: AppTextVariant.labelMedium,
                  color: colors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            subtitle,
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: colors.gold,
              inactiveTrackColor: AppColors.charcoal,
              thumbColor: colors.gold,
              overlayColor: colors.gold.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) / 100).round(),
              onChanged: (newValue) {
                setState(() {});
              },
              onChangeEnd: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                '${min.toStringAsFixed(0)}$suffix',
                variant: AppTextVariant.labelSmall,
                color: colors.textTertiary,
              ),
              AppText(
                '${max.toStringAsFixed(0)}$suffix',
                variant: AppTextVariant.labelSmall,
                color: colors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTypeToggle(AlertPreferences prefs, AlertType type, ThemeColors colors) {
    final isEnabled = prefs.alertTypes.contains(type);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(type.icon, color: type.color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  type.displayName,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                ),
                AppText(
                  type.description,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).toggleAlertType(type, value),
            activeColor: colors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSection(AlertPreferences prefs, ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Enable Quiet Hours',
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    'Mute non-critical alerts during set hours',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
              Switch(
                value: prefs.quietHoursEnabled,
                onChanged: (value) => ref.read(alertPreferencesProvider.notifier).setQuietHours(
                  enabled: value,
                  startTime: prefs.quietHoursStart,
                  endTime: prefs.quietHoursEnd,
                ),
                activeColor: colors.gold,
              ),
            ],
          ),
          if (prefs.quietHoursEnabled) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: 'Start',
                    time: prefs.quietHoursStart ?? '22:00',
                    onChanged: (time) => ref.read(alertPreferencesProvider.notifier).setQuietHours(
                      enabled: true,
                      startTime: time,
                      endTime: prefs.quietHoursEnd,
                    ),
                    colors: colors,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildTimePicker(
                    label: 'End',
                    time: prefs.quietHoursEnd ?? '07:00',
                    onChanged: (time) => ref.read(alertPreferencesProvider.notifier).setQuietHours(
                      enabled: true,
                      startTime: prefs.quietHoursStart,
                      endTime: time,
                    ),
                    colors: colors,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String time,
    required ValueChanged<String> onChanged,
    required ThemeColors colors,
  }) {
    return GestureDetector(
      onTap: () async {
        final parts = time.split(':');
        final initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );

        final picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: colors.gold,
                  surface: AppColors.slate,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          final newTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onChanged(newTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            AppText(
              label,
              variant: AppTextVariant.labelSmall,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              time,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigestFrequencySection(AlertPreferences prefs, ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'How often to receive alert summaries',
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          ...DigestFrequency.values.map((freq) => _buildDigestFrequencyOption(prefs, freq, colors)),
        ],
      ),
    );
  }

  Widget _buildDigestFrequencyOption(AlertPreferences prefs, DigestFrequency freq, ThemeColors colors) {
    final isSelected = prefs.digestFrequency == freq;

    return GestureDetector(
      onTap: () => ref.read(alertPreferencesProvider.notifier).updatePreferences(
        prefs.copyWith(digestFrequency: freq),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? colors.gold : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? colors.gold : colors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    freq.displayName,
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    freq.description,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetToDefault(AppLocalizations l10n, ThemeColors colors) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: AppText(
          'Reset to Default',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        content: AppText(
          'This will reset all your alert preferences to their default values. Continue?',
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(l10n.action_cancel, color: colors.textSecondary),
          ),
          AppButton(
            label: l10n.action_confirm,
            onPressed: () => Navigator.pop(context, true),
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(alertPreferencesProvider.notifier).resetToDefault();
    }
  }
}
