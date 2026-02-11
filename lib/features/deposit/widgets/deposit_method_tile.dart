import 'package:flutter/material.dart';
import '../providers/deposit_provider.dart';

/// Tile for selecting a deposit method.
class DepositMethodTile extends StatelessWidget {
  final DepositMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const DepositMethodTile({super.key, required this.method, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isSelected ? BorderSide(color: theme.colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: _methodColor(method).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_methodIcon(method), color: _methodColor(method), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    if (method.prefix.isNotEmpty)
                      Text(method.prefix, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 22)
              else
                Icon(Icons.radio_button_off_rounded, color: theme.colorScheme.outline, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  IconData _methodIcon(DepositMethod method) {
    switch (method) {
      case DepositMethod.orangeMoney: return Icons.phone_android_rounded;
      case DepositMethod.mtnMomo: return Icons.phone_android_rounded;
      case DepositMethod.moovMoney: return Icons.phone_android_rounded;
      case DepositMethod.wave: return Icons.phone_android_rounded;
      case DepositMethod.bankTransfer: return Icons.account_balance_rounded;
    }
  }

  Color _methodColor(DepositMethod method) {
    switch (method) {
      case DepositMethod.orangeMoney: return Colors.orange;
      case DepositMethod.mtnMomo: return Colors.yellow.shade700;
      case DepositMethod.moovMoney: return Colors.blue;
      case DepositMethod.wave: return Colors.blue.shade700;
      case DepositMethod.bankTransfer: return Colors.grey;
    }
  }
}
