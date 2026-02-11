import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../utils/formatters.dart';

/// Main wallet balance card shown on home screen.
class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    this.pendingBalance,
    this.isBalanceHidden = false,
    this.onToggleVisibility,
    this.onDeposit,
    this.onSend,
  });

  final double balance;
  final String currency;
  final double? pendingBalance;
  final bool isBalanceHidden;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onDeposit;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isBalanceHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isBalanceHidden
                ? '****'
                : formatCurrency(balance, currency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (pendingBalance != null && pendingBalance! > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Pending: ${formatCurrency(pendingBalance!, currency)}',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Deposit',
                  onTap: onDeposit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Send',
                  onTap: onSend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
