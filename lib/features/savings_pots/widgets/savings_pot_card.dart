import 'package:flutter/material.dart';
import '../../../domain/entities/savings_pot.dart';
import '../../../design/components/primitives/progress_bar.dart';

/// Card displaying a savings pot with progress.
class SavingsPotCard extends StatelessWidget {
  final SavingsPot pot;
  final VoidCallback? onTap;

  const SavingsPotCard({super.key, required this.pot, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.savings_rounded, color: theme.colorScheme.onPrimaryContainer, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pot.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        if (pot.daysRemaining != null)
                          Text('${pot.daysRemaining} days left', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (pot.isGoalReached)
                    Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 22),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${pot.currentAmount.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('of \$${pot.targetAmount.toStringAsFixed(2)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 8),
              ProgressBar(value: pot.progress, height: 6, showPercentage: false),
            ],
          ),
        ),
      ),
    );
  }
}
