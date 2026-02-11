import 'package:flutter/material.dart';
import '../../../domain/entities/transaction.dart';
import '../../../design/components/primitives/bottom_sheet_handle.dart';
import '../../../design/components/primitives/info_row.dart';
import '../../../design/components/primitives/pill_badge.dart';
import '../../../utils/clipboard_utils.dart';
import '../../../utils/color_utils.dart';
import '../../../utils/share_utils.dart';

/// Transaction detail bottom sheet.
class TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  static Future<void> show(BuildContext context, Transaction transaction) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => TransactionDetailSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCredit = transaction.isCredit;
    final statusColor = ColorUtils.statusColor(transaction.status.name, isDark: isDark);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHandle(title: 'Transaction Details', onClose: () => Navigator.pop(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                // Amount
                Text(
                  '${isCredit ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCredit ? Colors.green.shade700 : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                PillBadge(
                  label: transaction.status.name.toUpperCase(),
                  backgroundColor: statusColor.withOpacity(0.1),
                  textColor: statusColor,
                ),
                const SizedBox(height: 20),

                // Details
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        InfoRow(label: 'Type', value: transaction.type.name),
                        InfoRow(label: 'Date', value: '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}'),
                        if (transaction.fee != null && transaction.fee! > 0)
                          InfoRow(label: 'Fee', value: '\$${transaction.fee!.toStringAsFixed(2)}'),
                        if (transaction.recipientPhone != null)
                          InfoRow(label: 'Recipient', value: transaction.recipientPhone!),
                        if (transaction.description != null)
                          InfoRow(label: 'Description', value: transaction.description!),
                        InfoRow(label: 'Reference', value: transaction.reference),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ClipboardUtils.copyTransactionId(context, transaction.id),
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy ID'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => ShareUtils.shareTransactionReceipt(
                          transactionId: transaction.id,
                          amount: transaction.amount,
                          currency: transaction.currency,
                          recipientName: transaction.recipientPhone ?? 'N/A',
                          date: transaction.createdAt,
                          note: transaction.description,
                        ),
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
