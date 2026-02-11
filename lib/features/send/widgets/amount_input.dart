import 'package:flutter/material.dart';
import '../../../utils/input_formatters.dart';
import '../../../config/fee_schedule.dart';

/// Amount input widget with fee preview and balance check.
class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final double availableBalance;
  final String currency;
  final String? transferType;
  final ValueChanged<String>? onChanged;

  const AmountInput({
    super.key,
    required this.controller,
    required this.availableBalance,
    this.currency = 'USDC',
    this.transferType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Available: \$${availableBalance.toStringAsFixed(2)} $currency', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$', style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w300)),
            const SizedBox(width: 4),
            IntrinsicWidth(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [AmountInputFormatter(maxAmount: availableBalance)],
                style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, fontFeatures: const [FontFeature.tabularFigures()]),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0.00',
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                textAlign: TextAlign.center,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) {
            final amount = double.tryParse(value.text) ?? 0;
            final fee = _calculateFee(amount);
            final total = amount + fee;
            final exceedsBalance = total > availableBalance;

            return Column(
              children: [
                if (fee > 0)
                  Text('Fee: \$${fee.toStringAsFixed(2)} • Total: \$${total.toStringAsFixed(2)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                if (exceedsBalance && amount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Insufficient balance', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        // Quick amount buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [5, 10, 25, 50, 100].map((amount) {
            return ActionChip(
              label: Text('\$$amount'),
              onPressed: () {
                controller.text = amount.toString();
                onChanged?.call(amount.toString());
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  double _calculateFee(double amount) {
    if (transferType == 'internal') return FeeSchedule.internalTransfer(amount);
    if (transferType == 'external') return FeeSchedule.externalTransfer(amount);
    return 0;
  }
}
