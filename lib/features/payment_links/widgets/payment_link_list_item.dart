import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/payment_link.dart';
import 'package:usdc_wallet/utils/formatters.dart';

/// A single payment link list item.
class PaymentLinkListItem extends StatelessWidget {
  const PaymentLinkListItem({
    super.key,
    required this.link,
    this.onTap,
    this.onShare,
  });

  final PaymentLink link;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.link, color: colors.primary, size: 20),
      ),
      title: Text(
        link.description ?? 'Payment Link',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Text(
        link.amount != null // ignore: unnecessary_null_comparison
            ? formatCurrency(link.amount, link.currency)
            : 'Any amount',
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.share_outlined, color: colors.textSecondary),
        onPressed: onShare,
      ),
    );
  }
}
