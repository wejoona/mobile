import 'package:flutter/material.dart';
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
          Text(
            date,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          if (totalAmount != null)
            Text(
              totalAmount!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
