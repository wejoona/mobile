import 'package:flutter/material.dart';
import '../../../domain/entities/recurring_transfer.dart';
import '../../../utils/color_utils.dart';

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
    final avatarColor = ColorUtils.pastelFromString(transfer.recipientPhone);

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
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarColor,
                child: const Icon(Icons.repeat_rounded, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transfer.recipientName ?? transfer.recipientPhone,
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
                          '${transfer.frequencyLabel} • ${transfer.status.name}',
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
                  Text('${transfer.executionCount} sent', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
