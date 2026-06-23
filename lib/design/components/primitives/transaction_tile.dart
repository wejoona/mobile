import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/utils/color_utils.dart';
import 'package:usdc_wallet/utils/duration_extensions.dart';

/// Standard transaction list tile.
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCredit = transaction.isCredit;
    final isDebit = transaction.isDebit;
    final directionColor = isCredit
        ? Colors.green
        : isDebit
        ? Colors.red
        : theme.colorScheme.onSurfaceVariant;
    final directionIcon = isCredit
        ? Icons.arrow_downward_rounded
        : isDebit
        ? Icons.arrow_upward_rounded
        : Icons.receipt_long_rounded;
    final amountColor = isCredit
        ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
        : isDebit
        ? Colors.red
        : theme.colorScheme.onSurface;
    final statusColor = ColorUtils.statusColor(
      transaction.status.name,
      isDark: isDark,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: directionColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(directionIcon, color: directionColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ?? _typeLabel(transaction.type),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        transaction.createdAt.timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (transaction.isPending) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.status.name,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '${transaction.amountSign}\$${transaction.amount.abs().toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: amountColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.transferInternal:
        return 'Transfer';
      case TransactionType.transferExternal:
        return 'External Transfer';
      case TransactionType.billPayment:
        return 'Bill payment';
      case TransactionType.unknown:
        return 'Transaction';
    }
  }
}
