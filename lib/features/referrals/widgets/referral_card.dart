import 'package:usdc_wallet/design/components/primitives/gradient_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';

/// Run 381: Referral share card widget with copy-to-clipboard
class ReferralCard extends StatelessWidget {
  final String referralCode;
  final int referralCount;
  final double earnedAmount;

  const ReferralCard({
    super.key,
    required this.referralCode,
    this.referralCount = 0,
    this.earnedAmount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Icon(Icons.card_giftcard, color: AppColors.gold, size: 40),
            const SizedBox(height: AppSpacing.lg),
            const AppText(
              'Invitez vos amis',
              style: AppTextStyle.headingSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              'Gagnez 5 USDC pour chaque ami qui rejoint Korido',
              style: AppTextStyle.bodySmall,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Referral code
            Semantics(
              label: 'Code de parrainage: $referralCode',
              child: GestureDetector(
                onTap: () => _copyCode(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        referralCode,
                        style: AppTextStyle.headingSmall,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Icon(Icons.copy, color: AppColors.gold, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: 'Invitations',
                  value: '$referralCount',
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: AppColors.elevated,
                ),
                _StatItem(
                  label: 'Gains',
                  value: '${earnedAmount.toStringAsFixed(2)} USDC',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralCode));
    HapticService().lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copie!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(value, style: AppTextStyle.labelLarge, color: AppColors.textPrimary),
        const SizedBox(height: AppSpacing.xxs),
        AppText(label, style: AppTextStyle.bodySmall, color: AppColors.textTertiary),
      ],
    );
  }
}
