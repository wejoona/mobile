import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/payment_links/models/payment_link.dart';
import 'package:usdc_wallet/utils/clipboard_utils.dart';
import 'package:usdc_wallet/utils/share_utils.dart';

/// Card displaying a payment link.
class PaymentLinkCard extends StatelessWidget {
  final PaymentLink link;
  final VoidCallback? onTap;

  const PaymentLinkCard({super.key, required this.link, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = link.isPaid ? Colors.green : (link.isExpired ? Colors.grey : theme.colorScheme.primary);
    final statusLabel = link.isPaid ? 'Paid' : (link.isExpired ? 'Expired' : 'Active');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.link_rounded, color: theme.colorScheme.onPrimaryContainer, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\$${link.amount.toStringAsFixed(2)} ${link.currency}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        if (link.description != null)
                          Text(link.description!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              if (link.isActive) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ClipboardUtils.copy(link.url),
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy'),
                        style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => ShareUtils.sharePaymentLink(url: link.url, amount: link.amount, currency: link.currency, description: link.description),
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text('Share'),
                        style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
