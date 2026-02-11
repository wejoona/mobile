/// Consistent USDC amount display widget with formatting.
library;

import 'package:flutter/material.dart';

class AmountDisplay extends StatelessWidget {
  final double amount;
  final String currency;
  final TextStyle? style;
  final bool showSign;
  final bool isPositive;
  final bool colored;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.currency = 'USDC',
    this.style,
    this.showSign = false,
    this.isPositive = true,
    this.colored = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = style ?? theme.textTheme.titleLarge;
    final sign = showSign ? (isPositive ? '+' : '-') : '';
    final formatted = '$sign${amount.toStringAsFixed(2)} $currency';

    Color? textColor;
    if (colored) {
      textColor = isPositive
          ? const Color(0xFF2E7D32)
          : theme.colorScheme.error;
    }

    return Text(
      formatted,
      style: baseStyle?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
