import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/enums/index.dart';
import '../../../utils/formatters.dart';

/// A single transaction list item with icon, title, subtitle, and amount.
class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final Transaction transaction;
  final VoidCallback? onTap;

  IconData get _icon {
    switch (transaction.type) {
      case TransactionType.deposit:
        return Icons.arrow_downward_rounded;
      case TransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
      case TransactionType.transferInternal:
        return Icons.swap_horiz_rounded;
      case TransactionType.transferExternal:
        return Icons.open_in_new_rounded;
    }
  }

  Color _iconColor(BuildContext context) {
    final colors = context.colors;
    if (transaction.isCredit) return colors.success;
    if (transaction.isDebit) return colors.error;
    return colors.textSecondary;
  }

  String get _title {
    switch (transaction.type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.transferInternal:
        return transaction.isCredit ? 'Received' : 'Sent';
      case TransactionType.transferExternal:
        return 'External Transfer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final amountPrefix = transaction.isCredit ? '+' : '-';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _iconColor(context).withValues(alpha: 0.1),
        child: Icon(_icon, color: _iconColor(context), size: 20),
      ),
      title: Text(
        _title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Text(
        transaction.description ?? formatDate(transaction.createdAt),
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: Text(
        '$amountPrefix${formatCurrency(transaction.amount, transaction.currency)}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: transaction.isCredit ? colors.success : colors.textPrimary,
        ),
      ),
    );
  }
}
