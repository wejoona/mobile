/// Alert Detail View
/// Displays detailed information about a single alert with actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/index.dart';
import '../providers/index.dart';

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
    final alertAsync = ref.watch(alertDetailProvider(widget.alertId));

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Alert Details',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: alertAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold500),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.errorBase,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.lg),
              const AppText(
                'Failed to load alert',
                variant: AppTextVariant.titleMedium,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => ref.invalidate(alertDetailProvider(widget.alertId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (alert) {
          if (alert == null) {
            return const Center(
              child: AppText(
                'Alert not found',
                variant: AppTextVariant.titleMedium,
                color: AppColors.textSecondary,
              ),
            );
          }
          return _buildContent(alert);
        },
      ),
    );
  }

  Widget _buildContent(TransactionAlert alert) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert header
          _buildHeader(alert),
          const SizedBox(height: AppSpacing.xl),

          // Alert message
          _buildMessageSection(alert),
          const SizedBox(height: AppSpacing.xl),

          // Alert details
          _buildDetailsSection(alert),
          const SizedBox(height: AppSpacing.xl),

          // Transaction info (if available)
          if (alert.transactionId != null) ...[
            _buildTransactionSection(alert),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Action status
          if (alert.actionTaken != null) ...[
            _buildActionTakenSection(alert),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Quick actions
          if (alert.actionTaken == null) ...[
            _buildActionsSection(alert),
          ],

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildHeader(TransactionAlert alert) {
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
                          color: AppColors.errorBase,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const AppText(
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
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  alert.alertType.displayName,
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(TransactionAlert alert) {
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
            'Message',
            variant: AppTextVariant.labelMedium,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            alert.message,
            variant: AppTextVariant.bodyLarge,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(TransactionAlert alert) {
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
            'Details',
            variant: AppTextVariant.labelMedium,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow('Alert ID', alert.alertId.substring(0, 8)),
          _buildDetailRow('Type', alert.alertType.displayName),
          _buildDetailRow('Severity', alert.severity.displayName),
          _buildDetailRow('Created', _formatDateTime(alert.createdAt)),
          if (alert.amount != null)
            _buildDetailRow('Amount', '${alert.amount?.toStringAsFixed(2)} ${alert.currency ?? 'USD'}'),
        ],
      ),
    );
  }

  Widget _buildTransactionSection(TransactionAlert alert) {
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
            'Related Transaction',
            variant: AppTextVariant.labelMedium,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow('Transaction ID', alert.transactionId!.substring(0, 8)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/transactions/${alert.transactionId}'),
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('View Transaction'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold500,
                side: const BorderSide(color: AppColors.gold500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTakenSection(TransactionAlert alert) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.successBase.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.successBase.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.successBase,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Action Taken',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  alert.actionTaken!.displayName,
                  variant: AppTextVariant.bodyLarge,
                  color: AppColors.textPrimary,
                ),
                if (alert.actionTakenAt != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    _formatDateTime(alert.actionTakenAt!),
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(TransactionAlert alert) {
    final actions = alert.availableActions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Quick Actions',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        ...actions.map((action) => _buildActionButton(alert, action)),
      ],
    );
  }

  Widget _buildActionButton(TransactionAlert alert, AlertAction action) {
    final isPrimary = action == AlertAction.verifyIdentity ||
        action == AlertAction.blockRecipient;
    final isDanger = action == AlertAction.freezeAccount ||
        action == AlertAction.reportSuspicious;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: _isProcessingAction
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold500),
              )
            : OutlinedButton.icon(
                onPressed: () => _handleAction(alert, action),
                icon: Icon(action.icon, size: 20),
                label: Text(action.displayName),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDanger
                      ? AppColors.errorBase
                      : isPrimary
                          ? AppColors.gold500
                          : AppColors.textSecondary,
                  side: BorderSide(
                    color: isDanger
                        ? AppColors.errorBase
                        : isPrimary
                            ? AppColors.gold500
                            : AppColors.borderSubtle,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
          ),
          AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textPrimary,
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
      action,
    );

    setState(() => _isProcessingAction = false);

    if (success && mounted) {
      ref.invalidate(alertDetailProvider(widget.alertId));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Action "${action.displayName}" completed'),
          backgroundColor: AppColors.successBase,
        ),
      );

      if (action == AlertAction.dismiss) {
        context.pop();
      }
    }
  }

  Future<bool> _showConfirmationDialog(AlertAction action) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.elevated,
        title: AppText(
          'Confirm ${action.displayName}',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        content: AppText(
          _getConfirmationMessage(action),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: action == AlertAction.freezeAccount
                  ? AppColors.errorBase
                  : AppColors.gold500,
            ),
            child: const Text('Confirm'),
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
