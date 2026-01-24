import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class NotificationSettingsView extends ConsumerStatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  ConsumerState<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState
    extends ConsumerState<NotificationSettingsView> {
  // Push notifications
  bool _pushEnabled = true;
  bool _pushTransactions = true;
  bool _pushSecurity = true;
  bool _pushMarketing = false;

  // Email notifications
  bool _emailEnabled = true;
  bool _emailTransactions = true;
  bool _emailMonthlyStatement = true;
  bool _emailMarketing = false;

  // SMS notifications
  bool _smsEnabled = true;
  bool _smsTransactions = true;
  bool _smsSecurity = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Notification Settings',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push Notifications Section
            _buildSectionHeader(
              icon: Icons.notifications,
              title: 'Push Notifications',
              enabled: _pushEnabled,
              onChanged: (value) => setState(() {
                _pushEnabled = value;
                if (!value) {
                  _pushTransactions = false;
                  _pushSecurity = false;
                  _pushMarketing = false;
                }
              }),
            ),
            if (_pushEnabled) ...[
              _buildSettingTile(
                title: 'Transaction Alerts',
                subtitle: 'Get notified for deposits, transfers, and withdrawals',
                value: _pushTransactions,
                onChanged: (value) =>
                    setState(() => _pushTransactions = value),
              ),
              _buildSettingTile(
                title: 'Security Alerts',
                subtitle: 'Login attempts and account changes',
                value: _pushSecurity,
                onChanged: (value) => setState(() => _pushSecurity = value),
              ),
              _buildSettingTile(
                title: 'Promotions & Updates',
                subtitle: 'Special offers and new features',
                value: _pushMarketing,
                onChanged: (value) => setState(() => _pushMarketing = value),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // Email Notifications Section
            _buildSectionHeader(
              icon: Icons.email,
              title: 'Email Notifications',
              enabled: _emailEnabled,
              onChanged: (value) => setState(() {
                _emailEnabled = value;
                if (!value) {
                  _emailTransactions = false;
                  _emailMonthlyStatement = false;
                  _emailMarketing = false;
                }
              }),
            ),
            if (_emailEnabled) ...[
              _buildSettingTile(
                title: 'Transaction Receipts',
                subtitle: 'Receive email receipts for transactions',
                value: _emailTransactions,
                onChanged: (value) =>
                    setState(() => _emailTransactions = value),
              ),
              _buildSettingTile(
                title: 'Monthly Statements',
                subtitle: 'Get a monthly summary of your account',
                value: _emailMonthlyStatement,
                onChanged: (value) =>
                    setState(() => _emailMonthlyStatement = value),
              ),
              _buildSettingTile(
                title: 'Promotions & Newsletter',
                subtitle: 'Product updates and special offers',
                value: _emailMarketing,
                onChanged: (value) => setState(() => _emailMarketing = value),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // SMS Notifications Section
            _buildSectionHeader(
              icon: Icons.sms,
              title: 'SMS Notifications',
              enabled: _smsEnabled,
              onChanged: (value) => setState(() {
                _smsEnabled = value;
                if (!value) {
                  _smsTransactions = false;
                  _smsSecurity = false;
                }
              }),
            ),
            if (_smsEnabled) ...[
              _buildSettingTile(
                title: 'Transaction Alerts',
                subtitle: 'SMS for large transactions',
                value: _smsTransactions,
                onChanged: (value) => setState(() => _smsTransactions = value),
              ),
              _buildSettingTile(
                title: 'Security Codes',
                subtitle: 'OTP and security verification codes',
                value: _smsSecurity,
                onChanged: (value) => setState(() => _smsSecurity = value),
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
                  const Icon(Icons.info_outline, color: AppColors.infoBase, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: AppText(
                      'Security SMS notifications cannot be disabled. They are required for account protection.',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Save Button
            AppButton(
              label: 'Save Preferences',
              onPressed: _savePreferences,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.gold500.withValues(alpha: 0.2)
                  : AppColors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: enabled ? AppColors.gold500 : AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              title,
              variant: AppTextVariant.titleSmall,
              color: AppColors.textPrimary,
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
            activeColor: AppColors.gold500,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.elevated,
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
                      color: AppColors.textPrimary,
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
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isRequired ? true : value,
            onChanged: isRequired ? null : onChanged,
            activeColor: AppColors.gold500,
          ),
        ],
      ),
    );
  }

  Future<void> _savePreferences() async {
    // TODO: Save to API
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification preferences saved'),
          backgroundColor: AppColors.successBase,
        ),
      );
      context.pop();
    }
  }
}
