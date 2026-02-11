import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../domain/entities/recurring_transfer.dart';
import '../../../utils/formatters.dart';

/// A single recurring transfer list item.
class RecurringTransferListItem extends StatelessWidget {
  const RecurringTransferListItem({
    super.key,
    required this.transfer,
    this.onTap,
  });

  final RecurringTransfer transfer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: colors.primary.withValues(alpha: 0.1),
        child: Icon(Icons.repeat, color: colors.primary, size: 20),
      ),
      title: Text(
        transfer.recipientName ?? transfer.recipientPhone,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${transfer.frequency} - ${formatCurrency(transfer.amount, transfer.currency)}',
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: transfer.isActive
              ? colors.success.withValues(alpha: 0.1)
              : colors.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          transfer.isActive ? 'Active' : 'Paused',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: transfer.isActive ? colors.success : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
