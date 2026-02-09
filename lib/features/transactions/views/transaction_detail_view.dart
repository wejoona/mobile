import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/entities/index.dart';
import '../../../domain/enums/index.dart';
import '../../receipts/views/share_receipt_sheet.dart';

class TransactionDetailView extends ConsumerWidget {
  const TransactionDetailView({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final isPositive = transaction.amount >= 0;
    final statusColor = _getStatusColor(transaction.status);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.transactionDetails_title,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => ShareReceiptSheet.show(context, transaction),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Amount Card
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  // Status Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(transaction.status),
                      size: 36,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amount
                  AppText(
                    '${isPositive ? '+' : ''}\$${transaction.amount.abs().toStringAsFixed(2)}',
                    variant: AppTextVariant.displayMedium,
                    color: isPositive ? colors.successText : colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(transaction.type, colors).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: AppText(
                      transaction.type.name.toUpperCase(),
                      variant: AppTextVariant.labelSmall,
                      color: _getTypeColor(transaction.type, colors),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        transaction.status.name.toUpperCase(),
                        variant: AppTextVariant.labelMedium,
                        color: statusColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Details Card
            AppCard(
              variant: AppCardVariant.elevated,
              child: Column(
                children: [
                  _DetailRow(
                    label: l10n.transactionDetails_transactionId,
                    value: _truncateId(transaction.id),
                    onCopy: () => _copyToClipboard(context, transaction.id),
                    colors: colors,
                  ),
                  Divider(color: colors.borderSubtle),
                  _DetailRow(
                    label: l10n.transactionDetails_date,
                    value: DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt),
                    colors: colors,
                  ),
                  Divider(color: colors.borderSubtle),
                  _DetailRow(
                    label: l10n.transactionDetails_currency,
                    value: transaction.currency,
                    colors: colors,
                  ),
                  if (transaction.recipientPhone != null) ...[
                    Divider(color: colors.borderSubtle),
                    _DetailRow(
                      label: l10n.transactionDetails_recipientPhone,
                      value: transaction.recipientPhone!,
                      colors: colors,
                    ),
                  ],
                  if (transaction.recipientAddress != null) ...[
                    Divider(color: colors.borderSubtle),
                    _DetailRow(
                      label: l10n.transactionDetails_recipientAddress,
                      value: _truncateAddress(transaction.recipientAddress!),
                      onCopy: () => _copyToClipboard(context, transaction.recipientAddress!),
                      colors: colors,
                    ),
                  ],
                  if (transaction.description != null) ...[
                    Divider(color: colors.borderSubtle),
                    _DetailRow(
                      label: l10n.transactionDetails_description,
                      value: transaction.description!,
                      colors: colors,
                    ),
                  ],
                ],
              ),
            ),

            // Metadata (if deposit with source info)
            if (transaction.metadata != null && transaction.metadata!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppCard(
                variant: AppCardVariant.subtle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.transactionDetails_additionalDetails,
                      variant: AppTextVariant.labelMedium,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...transaction.metadata!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              _formatMetadataKey(entry.key),
                              variant: AppTextVariant.bodyMedium,
                              color: colors.textTertiary,
                            ),
                            Flexible(
                              child: AppText(
                                entry.value.toString(),
                                variant: AppTextVariant.bodyMedium,
                                color: colors.textPrimary,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            // Failed reason
            if (transaction.status == TransactionStatus.failed &&
                transaction.failureReason != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppCard(
                variant: AppCardVariant.subtle,
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colors.errorText,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            l10n.transactionDetails_failureReason,
                            variant: AppTextVariant.labelMedium,
                            color: colors.errorText,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppText(
                            transaction.failureReason!,
                            variant: AppTextVariant.bodyMedium,
                            color: colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxxl),

            // Help Button
            AppButton(
              label: l10n.help_needHelp,
              onPressed: () {
                context.push('/help');
              },
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
              icon: Icons.help_outline,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    // Note: We need a BuildContext to access theme colors, but this method
    // doesn't have access to colors. This method is used for the status icon
    // background, which should use hardcoded semantic colors for consistency.
    switch (status) {
      case TransactionStatus.completed:
        return AppColors.successBase;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return AppColors.warningBase;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppColors.errorBase;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Icons.check_circle;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return Icons.schedule;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getTypeColor(TransactionType type, ThemeColors colors) {
    switch (type) {
      case TransactionType.deposit:
        return colors.successText; // Green for deposits
      case TransactionType.withdrawal:
        return colors.errorText; // Red for withdrawals
      case TransactionType.transferInternal:
        return colors.infoText; // Blue for internal transfers
      case TransactionType.transferExternal:
        return colors.warning; // Orange/amber for external transfers
    }
  }

  String _truncateId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 6)}...${id.substring(id.length - 6)}';
  }

  String _truncateAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }

  String _formatMetadataKey(String key) {
    // Convert camelCase to Title Case
    return key
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  void _copyToClipboard(BuildContext context, String text) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.common_copiedToClipboard),
        backgroundColor: colors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareTransaction(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt);
    final amountStr = '\$${transaction.amount.abs().toStringAsFixed(2)}';
    final typeStr = _getTransactionTypeLabel(transaction.type);
    final statusStr = transaction.status.name.toUpperCase();

    final receiptText = '''
━━━━━━━━━━━━━━━━━━━━━━
      JOONAPAY RECEIPT
━━━━━━━━━━━━━━━━━━━━━━

Transaction ID: ${transaction.id.substring(0, 8)}...
Date: $dateStr
Type: $typeStr
Amount: $amountStr ${transaction.currency}
Status: $statusStr
${transaction.recipientPhone != null ? 'Recipient: ${transaction.recipientPhone}' : ''}
${transaction.description != null ? 'Note: ${transaction.description}' : ''}

━━━━━━━━━━━━━━━━━━━━━━
    Thank you for using
         JoonaPay
━━━━━━━━━━━━━━━━━━━━━━
''';

    Share.share(
      receiptText.trim(),
      subject: 'JoonaPay Transaction Receipt',
    );
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.transferInternal:
        return 'Transfer Received';
      case TransactionType.transferExternal:
        return 'Transfer Sent';
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.colors,
    this.onCopy,
  });

  final String label;
  final String value;
  final ThemeColors colors;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          Row(
            children: [
              AppText(
                value,
                variant: AppTextVariant.bodyMedium,
                color: colors.textPrimary,
              ),
              if (onCopy != null) ...[
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: onCopy,
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: colors.gold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
