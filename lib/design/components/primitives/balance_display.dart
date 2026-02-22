import 'package:flutter/material.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Wallet balance display with show/hide toggle and currency.
class BalanceDisplay extends StatelessWidget {
  final double amount;
  final String currency;
  final bool isVisible;
  final VoidCallback? onToggleVisibility;
  final TextStyle? amountStyle;
  final bool showCurrency;
  final bool compact;

  const BalanceDisplay({
    super.key,
    required this.amount,
    this.currency = 'USDC',
    this.isVisible = true,
    this.onToggleVisibility,
    this.amountStyle,
    this.showCurrency = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = compact
        ? theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          );

    final style = amountStyle ?? defaultStyle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isVisible
                ? (showCurrency
                    ? formatCurrency(amount, currency)
                    : _formatAmountOnly(amount, currency))
                : '••••••',
            key: ValueKey(isVisible),
            style: style,
          ),
        ),
        if (onToggleVisibility != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              isVisible
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }

  /// Format just the numeric amount without currency symbol/suffix.
  String _formatAmountOnly(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'XOF':
      case 'XAF':
        return formatXof(amount, showSymbol: false);
      default:
        return formatUsdc(amount, showSymbol: false);
    }
  }
}
