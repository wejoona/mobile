import 'package:flutter/material.dart';
import 'package:usdc_wallet/utils/input_formatters.dart';
import 'package:usdc_wallet/config/fee_schedule.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Approximate USDC to XOF rate (1 USDC ≈ 600 XOF).
/// In production this should come from the exchange rate provider.
const double _defaultUsdcToXofRate = 600.0;

/// Amount input widget with fee preview, balance check, and XOF conversion.
class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final double availableBalance;
  final String currency;
  final String? transferType;
  final ValueChanged<String>? onChanged;
  /// USDC → XOF exchange rate. Falls back to approximate rate.
  final double? exchangeRate;

  const AmountInput({
    super.key,
    required this.controller,
    required this.availableBalance,
    this.currency = 'USDC',
    this.transferType,
    this.onChanged,
    this.exchangeRate,
  });

  double get _rate => exchangeRate ?? _defaultUsdcToXofRate;

  String _formatXof(double usdc) {
    final xof = (usdc * _rate).round();
    // Add thousand separators with space (French convention)
    final str = xof.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return '${buf.toString()} XOF';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Solde disponible : \$${availableBalance.toStringAsFixed(2)} $currency', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text('≈ ${_formatXof(availableBalance)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$', style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w300)),
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
        const SizedBox(height: 4),
        // XOF equivalent of entered amount
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) {
            final amount = double.tryParse(value.text) ?? 0;
            if (amount <= 0) return const SizedBox.shrink();
            return Text(
              '≈ ${_formatXof(amount)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            );
          },
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
                  Text('Frais : \$${fee.toStringAsFixed(2)} • Total : \$${total.toStringAsFixed(2)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                if (exceedsBalance && amount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(AppLocalizations.of(context)!.wallet_insufficientBalance, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        // Quick amount buttons in XOF (what users think in)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [1000, 2000, 5000, 10000, 25000].map((xofAmount) {
            final usdcAmount = (xofAmount / _rate);
            final label = '${(xofAmount / 1000).toStringAsFixed(0)}k CFA';
            return ActionChip(
              label: Text(label),
              onPressed: () {
                controller.text = usdcAmount.toStringAsFixed(2);
                onChanged?.call(usdcAmount.toStringAsFixed(2));
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
