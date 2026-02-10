import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/virtual_card.dart';

/// Virtual Card Widget
///
/// Displays a premium card-like UI with theme-aware colors.
/// Features:
/// - Gold gradient for active cards
/// - Grayscale for frozen cards with overlay
/// - Premium shadows and glow effects
/// - Brand logo and card type indicators
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
    final isDark = colors.isDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: _buildCardGradient(isDark),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: _buildCardShadow(isDark),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            children: [
              // Frozen overlay (semi-transparent layer)
              if (card.isFrozen)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.ac_unit,
                        size: 64,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),

              // Status badge
              if (card.isFrozen || card.isBlocked || card.isExpired)
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: _buildStatusBadge(colors, card.status),
                ),

              // EMV chip
              Positioned(
                left: AppSpacing.lg,
                top: AppSpacing.xxl * 1.5,
                child: Container(
                  width: 48,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _buildChipColor(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.memory,
                      size: 20,
                      color: _buildChipIconColor(isDark),
                    ),
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
                  color: _buildTextColor(isDark),
                  fontWeight: FontWeight.w500,
                  style: const TextStyle(letterSpacing: 2.0),
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
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'CARDHOLDER',
                            variant: AppTextVariant.labelSmall,
                            color: _buildTextColor(isDark).withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          AppText(
                            card.cardholderName.toUpperCase(),
                            variant: AppTextVariant.labelMedium,
                            color: _buildTextColor(isDark),
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Expiry
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          'EXPIRES',
                          variant: AppTextVariant.labelSmall,
                          color: _buildTextColor(isDark).withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          card.expiry,
                          variant: AppTextVariant.labelMedium,
                          color: _buildTextColor(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Card brand logo (top right)
              Positioned(
                right: AppSpacing.lg,
                top: AppSpacing.md,
                child: AppText(
                  'Korido',
                  variant: AppTextVariant.labelLarge,
                  color: _buildTextColor(isDark),
                  fontWeight: FontWeight.bold,
                  style: const TextStyle(letterSpacing: 1.0),
                ),
              ),

              // Card type indicator (Visa/Mastercard style)
              Positioned(
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Icon(
                  Icons.credit_card,
                  size: 32,
                  color: _buildTextColor(isDark).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build gradient based on card status and theme
  LinearGradient _buildCardGradient(bool isDark) {
    if (card.isFrozen || card.isBlocked) {
      // Grayscale gradient for inactive cards
      return LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF3A3A3E),
                const Color(0xFF2A2A2E),
              ]
            : [
                const Color(0xFFCCCCCC),
                const Color(0xFFAAAAAA),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    // Premium gold gradient for active cards
    return LinearGradient(
      colors: isDark
          ? AppColors.goldGradient
          : [
              AppColorsLight.gold500,
              const Color(0xFFD4AA4A),
              AppColorsLight.gold500,
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Build shadow based on card status and theme
  List<BoxShadow>? _buildCardShadow(bool isDark) {
    if (card.isFrozen || card.isBlocked) {
      return isDark ? AppShadows.sm : AppShadows.lightSm;
    }
    return isDark ? AppShadows.goldGlow : AppShadows.lightCard;
  }

  /// Build EMV chip color
  Color _buildChipColor(bool isDark) {
    if (card.isFrozen || card.isBlocked) {
      return isDark
          ? Colors.white.withValues(alpha: 0.2)
          : Colors.black.withValues(alpha: 0.15);
    }
    return isDark
        ? AppColors.gold700
        : const Color(0xFF8A6E2B);
  }

  /// Build chip icon color
  Color _buildChipIconColor(bool isDark) {
    if (card.isFrozen || card.isBlocked) {
      return isDark
          ? Colors.white.withValues(alpha: 0.4)
          : Colors.black.withValues(alpha: 0.3);
    }
    return isDark
        ? AppColors.gold300
        : AppColorsLight.gold600;
  }

  /// Build text color for card content
  Color _buildTextColor(bool isDark) {
    // Always use high contrast text on card
    if (card.isFrozen || card.isBlocked) {
      return isDark ? Colors.white70 : Colors.black54;
    }
    // Dark text on gold gradient in light mode, white text in dark mode
    return isDark ? AppColors.textInverse : AppColorsLight.textInverse;
  }

  Widget _buildStatusBadge(ThemeColors colors, CardStatus status) {
    String label;
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (status) {
      case CardStatus.frozen:
        label = 'FROZEN';
        backgroundColor = colors.info.withValues(alpha: 0.2);
        textColor = colors.isDark ? colors.infoText : colors.info;
        borderColor = colors.info.withValues(alpha: 0.5);
        break;
      case CardStatus.blocked:
        label = 'BLOCKED';
        backgroundColor = colors.error.withValues(alpha: 0.2);
        textColor = colors.isDark ? colors.errorText : colors.error;
        borderColor = colors.error.withValues(alpha: 0.5);
        break;
      case CardStatus.expired:
        label = 'EXPIRED';
        backgroundColor = colors.warning.withValues(alpha: 0.2);
        textColor = colors.isDark ? colors.warningText : colors.warning;
        borderColor = colors.warning.withValues(alpha: 0.5);
        break;
      case CardStatus.active:
        label = 'ACTIVE';
        backgroundColor = colors.success.withValues(alpha: 0.2);
        textColor = colors.isDark ? colors.successText : colors.success;
        borderColor = colors.success.withValues(alpha: 0.5);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: borderColor),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.labelSmall,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _formatCardNumber(String number) {
    // Format as: 1234 5678 9012 3456
    if (number.length != 16) return number;
    return '${number.substring(0, 4)} ${number.substring(4, 8)} ${number.substring(8, 12)} ${number.substring(12, 16)}';
  }
}
