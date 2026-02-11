import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/entities/card.dart';

/// Run 383: Virtual/physical card display widget
class CardDisplay extends StatelessWidget {
  final KoridoCard card;
  final bool showDetails;
  final VoidCallback? onTap;

  const CardDisplay({
    super.key,
    required this.card,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carte ${card.isVirtual ? "virtuelle" : "physique"} '
          'se terminant par ${card.lastFourDigits}',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1.586, // Standard card ratio
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: card.isVirtual
                    ? [
                        const Color(0xFF1A1A2E),
                        const Color(0xFF16213E),
                        const Color(0xFF0F3460),
                      ]
                    : [
                        const Color(0xFF2D2D2D),
                        const Color(0xFF1A1A1A),
                        const Color(0xFF0D0D0D),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: brand + type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      'Korido',
                      style: AppTextStyle.labelLarge,
                      color: AppColors.gold,
                    ),
                    PillBadge(
                      label: card.type == CardType.virtual ? 'Virtuelle' : 'Physique',
                      backgroundColor: AppColors.gold,
                    ),
                  ],
                ),
                const Spacer(),
                // Card number
                AppText(
                  showDetails
                      ? _formatCardNumber(card.maskedNumber)
                      : '**** **** **** ${card.last4}',
                  style: AppTextStyle.headingSmall,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Bottom row: name + expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'TITULAIRE',
                          style: AppTextStyle.bodySmall,
                          color: AppColors.textTertiary,
                        ),
                        AppText(
                          (card.nickname ?? 'HOLDER').toUpperCase(),
                          style: AppTextStyle.labelMedium,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          'EXPIRE',
                          style: AppTextStyle.bodySmall,
                          color: AppColors.textTertiary,
                        ),
                        AppText(
                          card.expiryDate,
                          style: AppTextStyle.labelMedium,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCardNumber(String masked) {
    final clean = masked.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }
}
