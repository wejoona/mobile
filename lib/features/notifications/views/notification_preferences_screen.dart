import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/settings/providers/notification_preferences_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Notification Preferences Screen
///
/// Allows users to configure which types of notifications they want to receive.
/// Now uses the consolidated notification preferences provider from settings.
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationPreferencesProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.notifications_preferences_title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(context, ref, state, colors, l10n),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, NotificationPreferencesState state, ThemeColors colors, AppLocalizations l10n) {
    if (state.isLoading && !state.hasData) {
      return Center(
        child: CircularProgressIndicator(color: colors.gold),
      );
    }

    if (state.error != null && !state.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colors.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            AppText(
              l10n.error_generic,
              variant: AppTextVariant.bodyLarge,
              color: colors.textSecondary,
            ),
          ],
        ),
      );
    }

    final preferences = state.preferences;
    if (preferences == null) {
      return Center(
        child: CircularProgressIndicator(color: colors.gold),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        AppText(
          l10n.notifications_preferences_description,
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Push notifications
        _PreferenceSection(
          title: l10n.notifications_pref_transaction_title,
          children: [
            _PreferenceSwitch(
              label: l10n.notifications_pref_transaction_alerts,
              description: l10n.notifications_pref_transaction_alerts_desc,
              value: preferences.pushTransactions,
              onChanged: (value) {
                ref.read(notificationPreferencesProvider.notifier).setPushTransactions(value);
              },
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
              value: preferences.pushSecurity,
              onChanged: null,
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
              value: preferences.pushMarketing,
              onChanged: (value) {
                ref.read(notificationPreferencesProvider.notifier).setPushMarketing(value);
              },
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // Email notifications
        _PreferenceSection(
          title: l10n.notifications_pref_summary_title,
          children: [
            _PreferenceSwitch(
              label: l10n.notifications_pref_weekly_summary,
              description: l10n.notifications_pref_weekly_summary_desc,
              value: preferences.emailMonthlyStatement,
              onChanged: (value) {
                ref.read(notificationPreferencesProvider.notifier).setEmailMonthlyStatement(value);
              },
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

        _ThresholdCard(
          label: l10n.notifications_pref_large_transaction_threshold,
          value: preferences.largeTransactionThreshold,
          unit: 'USDC',
          onChanged: (value) {
            ref.read(notificationPreferencesProvider.notifier).setLargeTransactionThreshold(value);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        _ThresholdCard(
          label: l10n.notifications_pref_low_balance_threshold,
          value: preferences.lowBalanceThreshold,
          unit: 'USDC',
          onChanged: (value) {
            ref.read(notificationPreferencesProvider.notifier).setLowBalanceThreshold(value);
          },
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _PreferenceSection extends StatelessWidget {
  const _PreferenceSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(title, variant: AppTextVariant.titleMedium, color: colors.textPrimary),
        const SizedBox(height: AppSpacing.md),
        ...children,
      ],
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
    required this.label, required this.description,
    required this.value, required this.onChanged, this.locked = false,
  });
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                Row(children: [
                  Flexible(child: AppText(label, variant: AppTextVariant.bodyLarge, color: colors.textPrimary)),
                  if (locked) ...[const SizedBox(width: AppSpacing.xs), Icon(Icons.lock, size: 16, color: colors.gold)],
                ]),
                const SizedBox(height: AppSpacing.xxs),
                AppText(description, variant: AppTextVariant.bodySmall, color: colors.textSecondary),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.gold,
            activeTrackColor: colors.gold.withValues(alpha: 0.5),
            inactiveThumbColor: colors.textTertiary,
            inactiveTrackColor: colors.elevated,
          ),
        ],
      ),
    );
  }
}

class _ThresholdCard extends StatefulWidget {
  const _ThresholdCard({required this.label, required this.value, required this.unit, required this.onChanged});
  final String label;
  final double value;
  final String unit;
  final ValueChanged<double> onChanged;

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
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(widget.label, variant: AppTextVariant.bodyLarge, color: colors.textPrimary),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: colors.textPrimary, fontSize: 16),
                decoration: InputDecoration(
                  filled: true, fillColor: colors.elevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  hintText: '0', hintStyle: TextStyle(color: colors.textTertiary),
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) widget.onChanged(parsed);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: colors.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.md)),
              child: AppText(widget.unit, variant: AppTextVariant.bodyMedium, color: colors.gold),
            ),
          ]),
        ],
      ),
    );
  }
}
