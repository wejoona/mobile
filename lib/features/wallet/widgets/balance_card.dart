import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/wallet/providers/exchange_rate_provider.dart';

/// Main wallet balance card on home screen.
/// Shows USDC balance with XOF/CFA equivalent.
class BalanceCard extends ConsumerWidget {
  final double balance;
  final String currency;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.balance,
    this.currency = 'USDC',
    this.isVisible = true,
    required this.onToggleVisibility,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rateAsync = ref.watch(exchangeRateProvider);
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.flat,
      onTap: onTap,
      borderRadius: AppRadius.xxl,
      borderColor: colors.gold.withValues(alpha: colors.isDark ? 0.24 : 0.28),
      backgroundColor: Color.alphaBlend(
        colors.gold.withValues(alpha: colors.isDark ? 0.08 : 0.07),
        colors.container,
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Solde total',
                variant: AppTextVariant.labelLarge,
                color: colors.textSecondary,
              ),
              StatusPill(
                label: currency,
                tone: StatusTone.brand,
                compact: true,
                emphasis: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // USDC balance
          Row(
            children: [
              Expanded(
                child: AmountText(
                  amount: balance,
                  currencyCode: currency,
                  size: AmountTextSize.large,
                  color: colors.gold,
                  isHidden: !isVisible,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: onToggleVisibility,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                icon: Icon(
                  isVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: colors.textSecondary,
                  size: 20,
                ),
                tooltip: isVisible ? 'Masquer le solde' : 'Afficher le solde',
              ),
            ],
          ),
          // XOF/CFA equivalent
          const SizedBox(height: AppSpacing.sm),
          rateAsync.when(
            data: (rate) => AppText(
              isVisible ? '≈ ${rate.formatXof(balance)}' : '≈ •••••• FCFA',
              variant: AppTextVariant.moneySmall,
              color: colors.textSecondary,
            ),
            loading: () => AppText(
              '≈ ...',
              variant: AppTextVariant.moneySmall,
              color: colors.textTertiary,
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
