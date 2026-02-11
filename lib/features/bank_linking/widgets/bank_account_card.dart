import 'package:flutter/material.dart';
import '../../../domain/entities/bank_account.dart';

/// Card displaying a linked bank account.
class BankAccountCard extends StatelessWidget {
  final BankAccount account;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const BankAccountCard({super.key, required this.account, this.onTap, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.account_balance_rounded, color: theme.colorScheme.onSurfaceVariant, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(account.bankName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        if (account.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
                            child: Text('Default', style: TextStyle(fontSize: 10, color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(account.maskedAccount, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (account.isVerified)
                Icon(Icons.verified_rounded, color: Colors.green.shade600, size: 20)
              else if (account.isPending)
                Icon(Icons.hourglass_top_rounded, color: Colors.orange.shade600, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
