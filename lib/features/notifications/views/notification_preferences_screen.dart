import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/notification_preferences_notifier_provider.dart';

/// Notification Preferences Screen
///
/// Allows users to configure which types of notifications they want to receive.
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(notificationPreferencesNotifierProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.notifications_preferences_title,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.when(
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // Description
            AppText(
              l10n.notifications_preferences_description,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Transaction Alerts
            _PreferenceSection(
              title: l10n.notifications_pref_transaction_title,
              children: [
                _PreferenceSwitch(
                  label: l10n.notifications_pref_transaction_alerts,
                  description: l10n.notifications_pref_transaction_alerts_desc,
                  value: preferences.transactionAlerts,
                  onChanged: (value) {
                    ref
                        .read(notificationPreferencesNotifierProvider.notifier)
                        .updateTransactionAlerts(value);
                  },
                  colors: colors,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Security Alerts
            _PreferenceSection(
              title: l10n.notifications_pref_security_title,
              children: [
                _PreferenceSwitch(
                  label: l10n.notifications_pref_security_alerts,
                  description: l10n.notifications_pref_security_alerts_desc,
                  value: preferences.securityAlerts,
                  onChanged: null, // Security alerts cannot be disabled
                  colors: colors,
                  locked: true,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Promotional
            _PreferenceSection(
              title: l10n.notifications_pref_promotional_title,
              children: [
                _PreferenceSwitch(
                  label: l10n.notifications_pref_promotions,
                  description: l10n.notifications_pref_promotions_desc,
                  value: preferences.promotions,
                  onChanged: (value) {
                    ref
                        .read(notificationPreferencesNotifierProvider.notifier)
                        .updatePromotions(value);
                  },
                  colors: colors,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Price Alerts
            _PreferenceSection(
              title: l10n.notifications_pref_price_title,
              children: [
                _PreferenceSwitch(
                  label: l10n.notifications_pref_price_alerts,
                  description: l10n.notifications_pref_price_alerts_desc,
                  value: preferences.priceAlerts,
                  onChanged: (value) {
                    ref
                        .read(notificationPreferencesNotifierProvider.notifier)
                        .updatePriceAlerts(value);
                  },
                  colors: colors,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Weekly Summary
            _PreferenceSection(
              title: l10n.notifications_pref_summary_title,
              children: [
                _PreferenceSwitch(
                  label: l10n.notifications_pref_weekly_summary,
                  description: l10n.notifications_pref_weekly_summary_desc,
                  value: preferences.weeklySummary,
                  onChanged: (value) {
                    ref
                        .read(notificationPreferencesNotifierProvider.notifier)
                        .updateWeeklySummary(value);
                  },
                  colors: colors,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Threshold Settings
            AppText(
              l10n.notifications_pref_thresholds_title,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),

            const SizedBox(height: AppSpacing.md),

            AppText(
              l10n.notifications_pref_thresholds_description,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Large Transaction Threshold
            _ThresholdCard(
              label: l10n.notifications_pref_large_transaction_threshold,
              value: preferences.largeTransactionThreshold,
              unit: 'USDC',
              onChanged: (value) {
                ref
                    .read(notificationPreferencesNotifierProvider.notifier)
                    .updateLargeTransactionThreshold(value);
              },
              colors: colors,
            ),

            const SizedBox(height: AppSpacing.md),

            // Low Balance Threshold
            _ThresholdCard(
              label: l10n.notifications_pref_low_balance_threshold,
              value: preferences.lowBalanceThreshold,
              unit: 'USDC',
              onChanged: (value) {
                ref
                    .read(notificationPreferencesNotifierProvider.notifier)
                    .updateLowBalanceThreshold(value);
              },
              colors: colors,
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
        loading: () => Center(
          child: CircularProgressIndicator(color: colors.gold),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.errorBase, size: 48),
              const SizedBox(height: AppSpacing.md),
              AppText(
                l10n.error_generic,
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferenceSection extends StatelessWidget {
  const _PreferenceSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        ...children,
      ],
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    required this.colors,
    this.locked = false,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final ThemeColors colors;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
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
                      label,
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textPrimary,
                    ),
                    if (locked) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.lock,
                        size: 16,
                        color: colors.gold,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  description,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colors.gold,
            inactiveThumbColor: colors.textTertiary,
            inactiveTrackColor: colors.elevated,
          ),
        ],
      ),
    );
  }
}

class _ThresholdCard extends StatefulWidget {
  const _ThresholdCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.onChanged,
    required this.colors,
  });

  final String label;
  final double value;
  final String unit;
  final ValueChanged<double> onChanged;
  final ThemeColors colors;

  @override
  State<_ThresholdCard> createState() => _ThresholdCardState();
}

class _ThresholdCardState extends State<_ThresholdCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: widget.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: widget.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            widget.label,
            variant: AppTextVariant.bodyLarge,
            color: widget.colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: widget.colors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: widget.colors.elevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    hintText: '0',
                    hintStyle: TextStyle(color: widget.colors.textTertiary),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      widget.onChanged(parsed);
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: widget.colors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: AppText(
                  widget.unit,
                  variant: AppTextVariant.bodyMedium,
                  color: widget.colors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
