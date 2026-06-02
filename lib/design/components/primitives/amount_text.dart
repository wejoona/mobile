import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';

enum AmountTextSize { display, large, medium, small }

/// Canonical money text for Korido surfaces.
///
/// Uses DM Sans with tabular numerals so balances, receipts, and business
/// amounts feel stable instead of decorative.
class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    this.currencyCode = 'USDC',
    this.symbol = r'$',
    this.size = AmountTextSize.large,
    this.color,
    this.isHidden = false,
    this.compact = false,
    this.showCurrencyCode = false,
    this.signed = false,
    this.textAlign,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.semanticLabel,
  }) : text = null;

  const AmountText.fromText(
    this.text, {
    super.key,
    this.currencyCode = 'USDC',
    this.size = AmountTextSize.large,
    this.color,
    this.textAlign,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.semanticLabel,
  }) : amount = null,
       symbol = '',
       isHidden = false,
       compact = false,
       showCurrencyCode = false,
       signed = false;

  final num? amount;
  final String? text;
  final String currencyCode;
  final String symbol;
  final AmountTextSize size;
  final Color? color;
  final bool isHidden;
  final bool compact;
  final bool showCurrencyCode;
  final bool signed;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final value = text ?? _formatAmount();

    return AppText(
      value,
      variant: _variant,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticLabel: semanticLabel,
    );
  }

  AppTextVariant get _variant {
    switch (size) {
      case AmountTextSize.display:
        return AppTextVariant.moneyDisplay;
      case AmountTextSize.large:
        return AppTextVariant.moneyLarge;
      case AmountTextSize.medium:
        return AppTextVariant.moneyMedium;
      case AmountTextSize.small:
        return AppTextVariant.moneySmall;
    }
  }

  String _formatAmount() {
    if (isHidden) {
      final hidden = showCurrencyCode ? '•••• $currencyCode' : '••••••';
      return symbol.isEmpty ? hidden : '$symbol$hidden';
    }

    final value = amount ?? 0;
    final sign = value < 0
        ? '-'
        : signed && value > 0
        ? '+'
        : '';
    final absValue = value.abs();
    final formatted = compact
        ? _formatCompact(absValue)
        : _formatFull(absValue);
    final currency = showCurrencyCode ? ' $currencyCode' : '';

    return '$sign$symbol$formatted$currency';
  }

  String _formatFull(num value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '$whole.${parts[1]}';
  }

  String _formatCompact(num value) {
    if (value >= 1000000000) return '${_trim(value / 1000000000)}B';
    if (value >= 1000000) return '${_trim(value / 1000000)}M';
    if (value >= 1000) return '${_trim(value / 1000)}K';
    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2);
  }

  String _trim(num value) {
    final fixed = value.toStringAsFixed(value >= 10 ? 1 : 2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
