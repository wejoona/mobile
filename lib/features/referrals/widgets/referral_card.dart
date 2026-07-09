import 'package:usdc_wallet/design/components/primitives/gradient_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(Icons.card_giftcard, color: context.colors.gold, size: 40),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.referrals_invite,
              style: AppTextStyle.headingSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              '${l10n.referrals_earnAmount} ${l10n.referrals_earnDescription}',
              style: AppTextStyle.bodySmall,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Referral code
            Semantics(
              label: '${l10n.referrals_yourCode}: $referralCode',
              child: GestureDetector(
                onTap: () => _copyCode(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.elevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        referralCode,
                        style: AppTextStyle.headingSmall,
                        color: context.colors.gold,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Icon(Icons.copy, color: context.colors.gold, size: 18),
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
                  label: l10n.referrals_friendsInvited,
                  value: '$referralCount',
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: context.colors.borderSubtle,
                ),
                _StatItem(
                  label: l10n.referrals_totalEarned,
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
      SnackBar(
        content: Text(AppLocalizations.of(context)!.referrals_codeCopied),
        duration: const Duration(seconds: 2),
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
        AppText(value, style: AppTextStyle.labelLarge, color: context.colors.textPrimary),
        const SizedBox(height: AppSpacing.xxs),
        AppText(label, style: AppTextStyle.bodySmall, color: context.colors.textTertiary),
      ],
    );
  }
}
