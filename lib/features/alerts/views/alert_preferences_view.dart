/// Alert Preferences View
/// Allows users to customize their alert settings
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/index.dart';
import '../providers/index.dart';

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
    final state = ref.watch(alertPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Alert Preferences',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: state.isSaving
                ? null
                : () => _resetToDefault(),
            child: const AppText(
              'Reset',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold500),
            )
          : state.preferences == null
              ? const Center(
                  child: AppText(
                    'Failed to load preferences',
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.textSecondary,
                  ),
                )
              : Stack(
                  children: [
                    _buildContent(state.preferences!),
                    if (state.isSaving)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.gold500),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildContent(AlertPreferences prefs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Channels Section
          _buildSectionHeader('Notification Channels'),
          const SizedBox(height: AppSpacing.md),
          _buildChannelToggle(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive alerts on your device',
            value: prefs.pushAlerts,
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).togglePushAlerts(value),
          ),
          _buildChannelToggle(
            icon: Icons.email,
            title: 'Email Alerts',
            subtitle: 'Receive alerts via email',
            value: prefs.emailAlerts,
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).toggleEmailAlerts(value),
          ),
          _buildChannelToggle(
            icon: Icons.sms,
            title: 'SMS Alerts',
            subtitle: 'Receive critical alerts via SMS',
            value: prefs.smsAlerts,
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).toggleSmsAlerts(value),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Thresholds Section
          _buildSectionHeader('Alert Thresholds'),
          const SizedBox(height: AppSpacing.md),
          _buildThresholdSlider(
            title: 'Large Transaction Threshold',
            subtitle: 'Alert when transaction exceeds this amount',
            value: prefs.largeTransactionThreshold,
            min: 100,
            max: 10000,
            suffix: ' USD',
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).setLargeTransactionThreshold(value),
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
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Alert Types Section
          _buildSectionHeader('Alert Types'),
          const SizedBox(height: AppSpacing.sm),
          const AppText(
            'Choose which types of alerts you want to receive',
            variant: AppTextVariant.bodySmall,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          ...AlertType.values.map((type) => _buildAlertTypeToggle(prefs, type)),

          const SizedBox(height: AppSpacing.xxl),

          // Quiet Hours Section
          _buildSectionHeader('Quiet Hours'),
          const SizedBox(height: AppSpacing.md),
          _buildQuietHoursSection(prefs),

          const SizedBox(height: AppSpacing.xxl),

          // Critical Alerts
          _buildSectionHeader('Critical Alerts'),
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
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Digest Frequency
          _buildSectionHeader('Digest Frequency'),
          const SizedBox(height: AppSpacing.md),
          _buildDigestFrequencySection(prefs),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return AppText(
      title,
      variant: AppTextVariant.titleMedium,
      color: AppColors.textPrimary,
    );
  }

  Widget _buildChannelToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.slate,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.bodyLarge,
                  color: AppColors.textPrimary,
                ),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold500,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold500, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.bodyLarge,
                  color: AppColors.textPrimary,
                ),
                AppText(
                  subtitle,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold500,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.elevated,
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
                color: AppColors.textPrimary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold500.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: AppText(
                  '${value.toStringAsFixed(0)}$suffix',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.gold500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            subtitle,
            variant: AppTextVariant.bodySmall,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.gold500,
              inactiveTrackColor: AppColors.slate,
              thumbColor: AppColors.gold500,
              overlayColor: AppColors.gold500.withValues(alpha: 0.2),
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
                color: AppColors.textTertiary,
              ),
              AppText(
                '${max.toStringAsFixed(0)}$suffix',
                variant: AppTextVariant.labelSmall,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTypeToggle(AlertPreferences prefs, AlertType type) {
    final isEnabled = prefs.alertTypes.contains(type);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.elevated,
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
                  color: AppColors.textPrimary,
                ),
                AppText(
                  type.description,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => ref.read(alertPreferencesProvider.notifier).toggleAlertType(type, value),
            activeColor: AppColors.gold500,
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSection(AlertPreferences prefs) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.elevated,
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
                  const AppText(
                    'Enable Quiet Hours',
                    variant: AppTextVariant.bodyLarge,
                    color: AppColors.textPrimary,
                  ),
                  const AppText(
                    'Mute non-critical alerts during set hours',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
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
                activeColor: AppColors.gold500,
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
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.gold500,
                  surface: AppColors.elevated,
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
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            AppText(
              label,
              variant: AppTextVariant.labelSmall,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              time,
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigestFrequencySection(AlertPreferences prefs) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'How often to receive alert summaries',
            variant: AppTextVariant.bodySmall,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          ...DigestFrequency.values.map((freq) => _buildDigestFrequencyOption(prefs, freq)),
        ],
      ),
    );
  }

  Widget _buildDigestFrequencyOption(AlertPreferences prefs, DigestFrequency freq) {
    final isSelected = prefs.digestFrequency == freq;

    return GestureDetector(
      onTap: () => ref.read(alertPreferencesProvider.notifier).updatePreferences(
        prefs.copyWith(digestFrequency: freq),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold500.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.gold500 : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.gold500 : AppColors.textTertiary,
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
                    color: AppColors.textPrimary,
                  ),
                  AppText(
                    freq.description,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.elevated,
        title: const AppText(
          'Reset to Default',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        content: const AppText(
          'This will reset all your alert preferences to their default values. Continue?',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold500),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(alertPreferencesProvider.notifier).resetToDefault();
    }
  }
}
