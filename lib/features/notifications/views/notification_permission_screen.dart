import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/notifications/providers/notification_permission_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Notification Permission Screen
///
/// Shown on first launch or when user navigates from settings
/// to enable push notifications.
class NotificationPermissionScreen extends ConsumerWidget {
  const NotificationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final permissionState = ref.watch(notificationPermissionProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              // Close button (top right)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: colors.textSecondary),
                  onPressed: () => context.pop(),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),

                      // Illustration
                      Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(
                    color: colors.borderGold,
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background rings
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.gold.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.borderGold,
                          width: 1,
                        ),
                      ),
                    ),
                    // Bell icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors.gold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        color: colors.gold,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              AppText(
                l10n.notifications_permission_title,
                variant: AppTextVariant.headlineMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              // Description
              AppText(
                l10n.notifications_permission_description,
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Benefits
              _BenefitItem(
                icon: Icons.account_balance_wallet,
                title: l10n.notifications_benefit_transactions,
                description: l10n.notifications_benefit_transactions_desc,
              ),
              const SizedBox(height: AppSpacing.md),
              _BenefitItem(
                icon: Icons.security,
                title: l10n.notifications_benefit_security,
                description: l10n.notifications_benefit_security_desc,
              ),
              const SizedBox(height: AppSpacing.md),
              _BenefitItem(
                icon: Icons.trending_up,
                title: l10n.notifications_benefit_updates,
                description: l10n.notifications_benefit_updates_desc,
              ),

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),

              // Enable button (fixed at bottom)
              AppButton(
                label: l10n.notifications_enable_notifications,
                onPressed: () => _enableNotifications(context, ref),
                variant: AppButtonVariant.primary,
                isLoading: permissionState.isLoading,
                isFullWidth: true,
              ),

              const SizedBox(height: AppSpacing.md),

              // Maybe later button
              TextButton(
                onPressed: () => context.pop(),
                child: AppText(
                  l10n.notifications_maybe_later,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _enableNotifications(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(notificationPermissionProvider.notifier);
    final success = await notifier.requestPermission();

    if (context.mounted) {
      final colors = context.colors;
      if (success) {
        // Permission granted - navigate back or to next screen
        context.pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.notifications_enabled_success,
            ),
            backgroundColor: colors.success,
          ),
        );
      } else {
        // Permission denied - show settings guidance
        _showPermissionDeniedDialog(context);
      }
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.container,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: AppText(
          l10n.notifications_permission_denied_title,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        content: AppText(
          l10n.notifications_permission_denied_message,
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(
              l10n.action_cancel,
              color: colors.textSecondary,
            ),
          ),
          AppButton(
            label: l10n.action_open_settings,
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: colors.gold,
            size: 24,
          ),
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
              const SizedBox(height: AppSpacing.xxs),
              AppText(
                description,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
