import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/entities/index.dart';
import '../../../domain/enums/index.dart';

class TransactionDetailView extends ConsumerWidget {
  const TransactionDetailView({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPositive = transaction.amount >= 0;
    final statusColor = _getStatusColor(transaction.status);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Transaction Details',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareTransaction(context),
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
                    color: isPositive ? AppColors.successBase : AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(transaction.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: AppText(
                      transaction.type.name.toUpperCase(),
                      variant: AppTextVariant.labelSmall,
                      color: _getTypeColor(transaction.type),
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
                    label: 'Transaction ID',
                    value: _truncateId(transaction.id),
                    onCopy: () => _copyToClipboard(context, transaction.id),
                  ),
                  const Divider(color: AppColors.borderSubtle),
                  _DetailRow(
                    label: 'Date',
                    value: DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt),
                  ),
                  const Divider(color: AppColors.borderSubtle),
                  _DetailRow(
                    label: 'Currency',
                    value: transaction.currency,
                  ),
                  if (transaction.recipientPhone != null) ...[
                    const Divider(color: AppColors.borderSubtle),
                    _DetailRow(
                      label: 'Recipient Phone',
                      value: transaction.recipientPhone!,
                    ),
                  ],
                  if (transaction.recipientAddress != null) ...[
                    const Divider(color: AppColors.borderSubtle),
                    _DetailRow(
                      label: 'Recipient Address',
                      value: _truncateAddress(transaction.recipientAddress!),
                      onCopy: () => _copyToClipboard(context, transaction.recipientAddress!),
                    ),
                  ],
                  if (transaction.description != null) ...[
                    const Divider(color: AppColors.borderSubtle),
                    _DetailRow(
                      label: 'Description',
                      value: transaction.description!,
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
                    const AppText(
                      'Additional Details',
                      variant: AppTextVariant.labelMedium,
                      color: AppColors.textSecondary,
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
                              color: AppColors.textTertiary,
                            ),
                            Flexible(
                              child: AppText(
                                entry.value.toString(),
                                variant: AppTextVariant.bodyMedium,
                                color: AppColors.textPrimary,
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
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.errorBase,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            'Failure Reason',
                            variant: AppTextVariant.labelMedium,
                            color: AppColors.errorBase,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppText(
                            transaction.failureReason!,
                            variant: AppTextVariant.bodyMedium,
                            color: AppColors.textSecondary,
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
              label: 'Need Help?',
              onPressed: () {
                // TODO: Open support
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

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return AppColors.successBase;
      case TransactionType.withdrawal:
        return AppColors.warningBase;
      case TransactionType.transferInternal:
        return AppColors.infoBase;
      case TransactionType.transferExternal:
        return AppColors.gold500;
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
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: AppColors.successBase,
        duration: Duration(seconds: 2),
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
    this.onCopy,
  });

  final String label;
  final String value;
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
            color: AppColors.textSecondary,
          ),
          Row(
            children: [
              AppText(
                value,
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textPrimary,
              ),
              if (onCopy != null) ...[
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: onCopy,
                  child: const Icon(
                    Icons.copy,
                    size: 16,
                    color: AppColors.gold500,
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
