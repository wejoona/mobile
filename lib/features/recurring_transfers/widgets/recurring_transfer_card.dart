import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/user_avatar.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/transfer_frequency.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/recurring_transfer.dart';

/// Card showing a recurring transfer summary.
class RecurringTransferCard extends StatelessWidget {
  final RecurringTransfer transfer;
  final VoidCallback? onTap;

  const RecurringTransferCard({super.key, required this.transfer, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = transfer.isActive
        ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
        : (isDark ? Colors.orange.shade300 : Colors.orange.shade700);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              UserAvatar(
                firstName: (transfer.recipientName ?? transfer.recipientPhone).split(' ').first,
                lastName: (transfer.recipientName ?? '').split(' ').length > 1 ? (transfer.recipientName ?? '').split(' ').last : null,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // ignore: dead_null_aware_expression
                      transfer.recipientName ?? transfer.recipientPhone, // ignore: dead_code
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${transfer.frequency.getDisplayName('fr')} • ${transfer.status.name}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${transfer.amount.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text('${0} sent', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
