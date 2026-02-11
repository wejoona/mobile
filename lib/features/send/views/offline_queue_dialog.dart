import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/utils/formatters.dart';
import 'package:usdc_wallet/features/offline/providers/offline_provider.dart';

/// Helper function to format currency
String formatCurrency(double amount) => Formatters.formatCurrency(amount);

/// Dialog shown when queuing a transfer while offline
class OfflineQueueDialog extends ConsumerWidget {
  const OfflineQueueDialog({
    super.key,
    required this.recipientName,
    required this.recipientPhone,
    required this.amount,
    this.description,
  });

  final String? recipientName;
  final String recipientPhone;
  final double amount;
  final String? description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AlertDialog(
      backgroundColor: colors.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: colors.warningBase,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              l10n.offline_transferQueued,
              variant: AppTextVariant.titleMedium,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.offline_transferQueuedDesc,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Transfer summary
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                _buildRow(
                  l10n.send_recipient,
                  recipientName ?? recipientPhone,
                  colors,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildRow(
                  l10n.send_amount,
                  '\$${formatCurrency(amount)}',
                  colors,
                  isAmount: true,
                ),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildRow(
                    l10n.send_note,
                    description!,
                    colors,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: AppText(
            l10n.common_done,
            variant: AppTextVariant.labelMedium,
            color: colors.gold,
          ),
        ),
        AppButton(
          label: l10n.offline_viewPending,
          onPressed: () {
            Navigator.pop(context);
            context.push('/offline/pending-transfers');
          },
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.small,
        ),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String value,
    ThemeColors colors, {
    bool isAmount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: colors.textSecondary,
        ),
        AppText(
          value,
          variant: isAmount ? AppTextVariant.titleMedium : AppTextVariant.bodyMedium,
          color: isAmount ? colors.gold : colors.textPrimary,
          fontWeight: isAmount ? FontWeight.w700 : FontWeight.normal,
        ),
      ],
    );
  }

  /// Show the dialog and queue the transfer
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String? recipientName,
    required String recipientPhone,
    required double amount,
    String? description,
  }) async {
    // Queue the transfer
    final offlineNotifier = ref.read(offlineProvider.notifier);
    await offlineNotifier.queueTransfer(
      recipientPhone: recipientPhone,
      recipientName: recipientName,
      amount: amount,
      description: description,
    );

    // Show dialog
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => OfflineQueueDialog(
          recipientName: recipientName,
          recipientPhone: recipientPhone,
          amount: amount,
          description: description,
        ),
      );
    }
  }
}
