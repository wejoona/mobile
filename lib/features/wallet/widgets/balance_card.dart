import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/gradient_card.dart';
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

    return GradientCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde total',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // USDC balance
          Row(
            children: [
              Text(
                isVisible ? '\$${balance.toStringAsFixed(2)}' : '\$••••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 22,
                ),
              ),
            ],
          ),
          // XOF/CFA equivalent
          const SizedBox(height: 6),
          rateAsync.when(
            data: (rate) => Text(
              isVisible ? '≈ ${rate.formatXof(balance)}' : '≈ •••••• FCFA',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            loading: () => Text(
              '≈ ...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 16,
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
