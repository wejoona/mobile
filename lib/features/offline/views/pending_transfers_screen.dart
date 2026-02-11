import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/utils/formatters.dart';
import 'package:usdc_wallet/features/offline/providers/offline_provider.dart';
import 'package:usdc_wallet/services/offline/pending_transfer_queue.dart';

/// Helper function to format currency
String formatCurrency(double amount) => Formatters.formatCurrency(amount);

/// Pending Transfers Screen
/// Shows all pending offline transfers and their status
class PendingTransfersScreen extends ConsumerWidget {
  const PendingTransfersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final offlineState = ref.watch(offlineProvider);
    final colors = context.colors;

    final pendingTransfers = ref.read(offlineProvider.notifier).getPendingTransfers();

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.offline_pendingTransfer,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          if (pendingTransfers.isNotEmpty)
            TextButton(
              onPressed: () => _showClearConfirmation(context, ref, l10n),
              child: AppText(
                l10n.action_clearAll,
                variant: AppTextVariant.labelMedium,
                color: colors.error,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: pendingTransfers.isEmpty
            ? _buildEmptyState(context, l10n, colors)
            : RefreshIndicator(
                onRefresh: () async {
                  await ref.read(offlineProvider.notifier).manualSync();
                },
                color: colors.gold,
                backgroundColor: colors.container,
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: pendingTransfers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final transfer = pendingTransfers[index];
                    return _buildTransferCard(
                      context,
                      ref,
                      transfer,
                      l10n,
                      colors,
                      offlineState.isOnline,
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.textTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(
                Icons.cloud_done_outlined,
                color: colors.textTertiary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.home_noTransactionsYet,
              variant: AppTextVariant.titleMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'No pending offline transfers',
              variant: AppTextVariant.bodySmall,
              color: colors.textTertiary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferCard(
    BuildContext context,
    WidgetRef ref,
    PendingTransfer transfer,
    AppLocalizations l10n,
    ThemeColors colors,
    bool isOnline,
  ) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(transfer.status, colors),
              AppText(
                _formatTimestamp(transfer.timestamp),
                variant: AppTextVariant.bodySmall,
                color: colors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Recipient
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.gold.withValues(alpha: 0.2),
                child: Icon(
                  Icons.person_outline,
                  color: colors.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      transfer.recipientName ?? transfer.recipientPhone,
                      variant: AppTextVariant.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                    if (transfer.recipientName != null)
                      AppText(
                        transfer.recipientPhone,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                l10n.send_amount,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
              AppText(
                '\$${formatCurrency(transfer.amount)}',
                variant: AppTextVariant.titleMedium,
                color: colors.gold,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),

          // Description
          if (transfer.description != null && transfer.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            AppText(
              transfer.description!,
              variant: AppTextVariant.bodySmall,
              color: colors.textTertiary,
            ),
          ],

          // Error message for failed transfers
          if (transfer.status == TransferStatus.failed &&
              transfer.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colors.error,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText(
                      transfer.errorMessage!,
                      variant: AppTextVariant.bodySmall,
                      color: colors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Actions
          if (transfer.status == TransferStatus.failed ||
              transfer.status == TransferStatus.pending) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (transfer.status == TransferStatus.failed && isOnline)
                  Expanded(
                    child: AppButton(
                      label: l10n.offline_retryFailed,
                      onPressed: () => _retryTransfer(ref, transfer.id),
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.small,
                    ),
                  ),
                if (transfer.status == TransferStatus.pending ||
                    transfer.status == TransferStatus.failed) ...[
                  if (transfer.status == TransferStatus.failed && isOnline)
                    const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: l10n.offline_cancelTransfer,
                      onPressed: () =>
                          _cancelTransfer(context, ref, transfer, l10n),
                      variant: AppButtonVariant.danger,
                      size: AppButtonSize.small,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(TransferStatus status, ThemeColors colors) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case TransferStatus.pending:
        backgroundColor = colors.warningBase.withValues(alpha: 0.15);
        textColor = colors.warningText;
        label = 'Pending';
        icon = Icons.schedule;
        break;
      case TransferStatus.processing:
        backgroundColor = colors.gold.withValues(alpha: 0.15);
        textColor = colors.gold;
        label = 'Processing';
        icon = Icons.sync;
        break;
      case TransferStatus.completed:
        backgroundColor = colors.success.withValues(alpha: 0.15);
        textColor = colors.success;
        label = 'Completed';
        icon = Icons.check_circle_outline;
        break;
      case TransferStatus.failed:
        backgroundColor = colors.error.withValues(alpha: 0.15);
        textColor = colors.error;
        label = 'Failed';
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: AppSpacing.xs),
          AppText(
            label,
            variant: AppTextVariant.labelSmall,
            color: textColor,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _retryTransfer(WidgetRef ref, String transferId) async {
    await ref.read(offlineProvider.notifier).retryFailedTransfer(transferId);
  }

  Future<void> _cancelTransfer(
    BuildContext context,
    WidgetRef ref,
    PendingTransfer transfer,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(
          l10n.offline_cancelTransfer,
          variant: AppTextVariant.titleMedium,
        ),
        content: AppText(
          'Are you sure you want to cancel this transfer to ${transfer.recipientName ?? transfer.recipientPhone}?',
          variant: AppTextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: AppText(l10n.common_cancel),
          ),
          AppButton(
            label: l10n.common_delete,
            onPressed: () => Navigator.pop(ctx, true),
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(offlineProvider.notifier).cancelPendingTransfer(transfer.id);
    }
  }

  Future<void> _showClearConfirmation(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.container,
        title: AppText(
          l10n.action_clearAll,
          variant: AppTextVariant.titleMedium,
        ),
        content: AppText(
          'Clear all completed and failed transfers? Pending transfers will remain.',
          variant: AppTextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: AppText(l10n.common_cancel),
          ),
          AppButton(
            label: l10n.action_clearAll,
            onPressed: () => Navigator.pop(ctx, true),
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear logic would go here
    }
  }
}
