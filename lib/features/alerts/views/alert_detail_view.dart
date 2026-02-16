/// Alert Detail View
/// Displays detailed information about a single alert with actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/alerts/models/index.dart';
import 'package:usdc_wallet/features/alerts/providers/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class AlertDetailView extends ConsumerStatefulWidget {
  const AlertDetailView({
    super.key,
    required this.alertId,
  });

  final String alertId;

  @override
  ConsumerState<AlertDetailView> createState() => _AlertDetailViewState();
}

class _AlertDetailViewState extends ConsumerState<AlertDetailView> {
  bool _isProcessingAction = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final alertAsync = ref.watch(alertDetailProvider(widget.alertId));

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          "Détails de l'alerte",
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: alertAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: colors.gold),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: context.colors.error,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppText(
                "Impossible de charger l'alerte",
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.action_retry,
                onPressed: () => ref.invalidate(alertDetailProvider(widget.alertId)),
                size: AppButtonSize.small,
              ),
            ],
          ),
        ),
        data: (alert) {
          // ignore: unnecessary_null_comparison, dead_code
          if (alert == null) {
            return Center(
              child: AppText(
                'Alerte introuvable',
                variant: AppTextVariant.titleMedium,
                color: colors.textSecondary,
              ),
            );
          }
          return _buildContent(alert, colors, l10n);
        },
      ),
    );
  }

  Widget _buildContent(TransactionAlert alert, ThemeColors colors, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert header
          _buildHeader(alert, colors),
          const SizedBox(height: AppSpacing.xl),

          // Alert message
          _buildMessageSection(alert, colors),
          const SizedBox(height: AppSpacing.xl),

          // Alert details
          _buildDetailsSection(alert, colors),
          const SizedBox(height: AppSpacing.xl),

          // Transaction info (if available)
          if (alert.transactionId != null) ...[
            _buildTransactionSection(alert, colors),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Action status
          if (alert.actionTaken != null) ...[
            _buildActionTakenSection(alert, colors),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Quick actions
          if (alert.actionTaken == null) ...[
            _buildActionsSection(alert, colors),
          ],

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildHeader(TransactionAlert alert, ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: alert.alertType.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: alert.alertType.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: alert.alertType.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              alert.alertType.icon,
              color: alert.alertType.color,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: alert.severity.backgroundColor,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: AppText(
                        alert.severity.displayName.toUpperCase(),
                        variant: AppTextVariant.labelSmall,
                        color: alert.severity.color,
                      ),
                    ),
                    if (alert.isActionRequired && alert.actionTaken == null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.error,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: AppText(
                          'ACTION REQUIRED',
                          variant: AppTextVariant.labelSmall,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppText(
                  alert.title,
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  alert.alertType.displayName,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(TransactionAlert alert, ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Message',
            variant: AppTextVariant.labelMedium,
            color: colors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            alert.message,
            variant: AppTextVariant.bodyLarge,
            color: colors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(TransactionAlert alert, ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Détails',
            variant: AppTextVariant.labelMedium,
            color: colors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow('Alert ID', alert.alertId.substring(0, 8), colors),
          _buildDetailRow('Type', alert.alertType.displayName, colors),
          _buildDetailRow('Severity', alert.severity.displayName, colors),
          _buildDetailRow('Created', _formatDateTime(alert.createdAt), colors),
          if (alert.amount != null)
            _buildDetailRow('Amount', '${alert.amount?.toStringAsFixed(2)} ${alert.currency ?? 'USD'}', colors),
        ],
      ),
    );
  }

  Widget _buildTransactionSection(TransactionAlert alert, ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Transaction associée',
            variant: AppTextVariant.labelMedium,
            color: colors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow('Transaction ID', alert.transactionId!.substring(0, 8), colors),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/transactions/${alert.transactionId}'),
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('View Transaction'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.gold,
                side: BorderSide(color: colors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTakenSection(TransactionAlert alert, ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.colors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: context.colors.success,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Action effectuée',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  alert.actionTaken!.displayName,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textPrimary,
                ),
                if (alert.actionTakenAt != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    _formatDateTime(alert.actionTakenAt!),
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(TransactionAlert alert, ThemeColors colors) {
    final actions = alert.availableActions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Actions rapides',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        ...actions.map((action) => _buildActionButton(alert, action, colors)),
      ],
    );
  }

  Widget _buildActionButton(TransactionAlert alert, AlertAction action, ThemeColors colors) {
    final isPrimary = action == AlertAction.verifyIdentity ||
        action == AlertAction.blockRecipient;
    final isDanger = action == AlertAction.freezeAccount ||
        action == AlertAction.reportSuspicious;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: _isProcessingAction
            ? Center(
                child: CircularProgressIndicator(color: colors.gold),
              )
            : OutlinedButton.icon(
                onPressed: () => _handleAction(alert, action),
                icon: Icon(action.icon, size: 20),
                label: Text(action.displayName),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDanger
                      ? context.colors.error
                      : isPrimary
                          ? colors.gold
                          : colors.textSecondary,
                  side: BorderSide(
                    color: isDanger
                        ? context.colors.error
                        : isPrimary
                            ? colors.gold
                            : context.colors.borderSubtle,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            color: colors.textPrimary,
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(TransactionAlert alert, AlertAction action) async {
    // Show confirmation for dangerous actions
    if (action == AlertAction.freezeAccount || action == AlertAction.blockRecipient) {
      final confirmed = await _showConfirmationDialog(action);
      if (!confirmed) return;
    }

    setState(() => _isProcessingAction = true);

    final success = await ref.read(alertsProvider.notifier).takeAction(
      alert.alertId,
      action.name,
    );

    setState(() => _isProcessingAction = false);

    if (success && mounted) {
      ref.invalidate(alertDetailProvider(widget.alertId));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Action "${action.displayName}" completed'),
          backgroundColor: context.colors.success,
        ),
      );

      if (action == AlertAction.dismiss) {
        context.pop();
      }
    }
  }

  Future<bool> _showConfirmationDialog(AlertAction action) async {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(
          'Confirm ${action.displayName}',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        content: AppText(
          _getConfirmationMessage(action),
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

    return result ?? false;
  }

  String _getConfirmationMessage(AlertAction action) {
    switch (action) {
      case AlertAction.freezeAccount:
        return 'This will temporarily freeze your account. You will need to contact support to unfreeze it.';
      case AlertAction.blockRecipient:
        return 'This will prevent any future transactions to this recipient. You can unblock them later in settings.';
      default:
        return 'Are you sure you want to proceed?';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (date == today) {
      return 'Today at $timeStr';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at $timeStr';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at $timeStr';
    }
  }
}
