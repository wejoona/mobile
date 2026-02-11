import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/balance_display.dart';
import 'package:usdc_wallet/design/components/primitives/gradient_card.dart';

/// Main wallet balance card on home screen.
class BalanceCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Balance', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(currency, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                isVisible ? '\$${balance.toStringAsFixed(2)}' : '\$••••••',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()]),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: Colors.white.withOpacity(0.5),
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
