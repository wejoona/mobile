import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/virtual_card.dart';

/// Virtual Card Widget
///
/// Displays a card-like UI with card details
class VirtualCardWidget extends StatelessWidget {
  const VirtualCardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.showFullNumber = false,
  });

  final VirtualCard card;
  final VoidCallback? onTap;
  final bool showFullNumber;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: card.isFrozen
              ? LinearGradient(
                  colors: [
                    colors.textSecondary,
                    colors.textTertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: AppColors.goldGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: card.isFrozen ? null : AppShadows.goldGlow,
        ),
        child: Stack(
          children: [
            // Status badge
            if (card.isFrozen || card.isBlocked)
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: _buildStatusBadge(card.status),
              ),

            // EMV chip
            Positioned(
              left: AppSpacing.lg,
              top: AppSpacing.xxl * 1.5,
              child: Container(
                width: 48,
                height: 36,
                decoration: BoxDecoration(
                  color: card.isFrozen
                      ? AppColors.textInverse.withValues(alpha: 0.3)
                      : AppColors.gold700,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),

            // Card number
            Positioned(
              left: AppSpacing.lg,
              bottom: AppSpacing.huge * 1.5,
              child: AppText(
                showFullNumber ? _formatCardNumber(card.cardNumber) : card.maskedNumber,
                variant: AppTextVariant.headlineSmall,
                color: AppColors.textInverse,
                letterSpacing: 2,
              ),
            ),

            // Bottom row: Cardholder and Expiry
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cardholder name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'CARDHOLDER',
                        variant: AppTextVariant.labelSmall,
                        color: AppColors.textInverse.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        card.cardholderName.toUpperCase(),
                        variant: AppTextVariant.labelMedium,
                        color: AppColors.textInverse,
                      ),
                    ],
                  ),

                  // Expiry
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(
                        'EXPIRES',
                        variant: AppTextVariant.labelSmall,
                        color: AppColors.textInverse.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        card.expiry,
                        variant: AppTextVariant.labelMedium,
                        color: AppColors.textInverse,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Card brand logo
            Positioned(
              right: AppSpacing.lg,
              top: AppSpacing.md,
              child: AppText(
                'JoonaPay',
                variant: AppTextVariant.labelLarge,
                color: AppColors.textInverse,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(CardStatus status) {
    String label;
    Color color;

    switch (status) {
      case CardStatus.frozen:
        label = 'FROZEN';
        color = AppColors.info;
        break;
      case CardStatus.blocked:
        label = 'BLOCKED';
        color = AppColors.error;
        break;
      case CardStatus.expired:
        label = 'EXPIRED';
        color = AppColors.warning;
        break;
      case CardStatus.active:
        label = 'ACTIVE';
        color = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.labelSmall,
        color: AppColors.textInverse,
      ),
    );
  }

  String _formatCardNumber(String number) {
    // Format as: 1234 5678 9012 3456
    if (number.length != 16) return number;
    return '${number.substring(0, 4)} ${number.substring(4, 8)} ${number.substring(8, 12)} ${number.substring(12, 16)}';
  }
}
