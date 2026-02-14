import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/domain/entities/savings_pot.dart';
import 'package:intl/intl.dart';

/// Card widget displaying a savings pot
class PotCard extends StatelessWidget {
  const PotCard({
    super.key,
    required this.pot,
    required this.onTap,
  });

  final SavingsPot pot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: pot.color.withValues(alpha: colors.isDark ? 0.3 : 0.4),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji with progress ring if goal is set
            if (pot.targetAmount != null)
              _buildProgressRing(context)
            else
              Text(
                pot.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            SizedBox(height: AppSpacing.sm),

            // Pot name
            AppText(
              pot.name,
              variant: AppTextVariant.bodyLarge,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: AppSpacing.xs),

            // Current amount
            AppText(
              currencyFormat.format(pot.currentAmount),
              variant: AppTextVariant.headlineSmall,
              color: pot.color,
              fontWeight: FontWeight.bold,
            ),

            // Progress bar if goal is set
            if (pot.targetAmount != null) ...[
              SizedBox(height: AppSpacing.sm),
              _buildProgressBar(context),
              SizedBox(height: AppSpacing.xs),
              AppText(
                'of ${currencyFormat.format(pot.targetAmount)} (${(pot.progress! * 100).toStringAsFixed(0)}%)',
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing(BuildContext context) {
    final colors = context.colors;
    final trackOpacity = colors.isDark ? 0.2 : 0.15;

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: pot.progress,
              strokeWidth: 3,
              backgroundColor: pot.color.withValues(alpha: trackOpacity),
              valueColor: AlwaysStoppedAnimation<Color>(pot.color),
            ),
          ),
          Text(
            pot.emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final colors = context.colors;
    final trackOpacity = colors.isDark ? 0.2 : 0.15;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: LinearProgressIndicator(
        value: pot.progress,
        minHeight: 6,
        backgroundColor: pot.color.withValues(alpha: trackOpacity),
        valueColor: AlwaysStoppedAnimation<Color>(pot.color),
      ),
    );
  }
}
