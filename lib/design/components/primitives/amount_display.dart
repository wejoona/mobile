import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/semantic_colors.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Display a monetary amount with appropriate formatting and color.
/// Uses formatCurrency() which respects XOF/FCFA formatting rules.
class AmountDisplay extends StatelessWidget {
  final double amount;
  final String currency;
  final bool showSign;
  final bool isIncoming;
  final double fontSize;
  
  const AmountDisplay({
    super.key,
    required this.amount,
    this.currency = 'USDC',
    this.showSign = true,
    this.isIncoming = true,
    this.fontSize = 16,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = isIncoming ? SemanticColors.moneyIn : SemanticColors.moneyOut;
    final sign = showSign ? (isIncoming ? '+' : '-') : '';
    
    return Text(
      '$sign${formatCurrency(amount.abs(), currency)}',
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
