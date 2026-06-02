import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Date section header for grouped transaction lists.
class TransactionDateHeader extends StatelessWidget {
  const TransactionDateHeader({
    super.key,
    required this.date,
    this.totalAmount,
  });

  final String date;
  final String? totalAmount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            date,
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          if (totalAmount != null)
            AmountText.fromText(
              totalAmount,
              size: AmountTextSize.small,
              color: colors.textSecondary,
            ),
        ],
      ),
    );
  }
}
