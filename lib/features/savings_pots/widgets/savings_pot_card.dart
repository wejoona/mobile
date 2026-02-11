import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../domain/entities/savings_pot.dart';
import '../../../utils/formatters.dart';

/// Card widget for a single savings pot.
class SavingsPotCard extends StatelessWidget {
  const SavingsPotCard({
    super.key,
    required this.pot,
    this.onTap,
  });

  final SavingsPot pot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = pot.targetAmount > 0
        ? (pot.currentAmount / pot.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings_outlined, color: colors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pot.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colors.border,
                valueColor: AlwaysStoppedAnimation(colors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCurrency(pot.currentAmount, pot.currency),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'of ${formatCurrency(pot.targetAmount, pot.currency)}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
