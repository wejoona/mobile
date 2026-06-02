import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/amount_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

class MoneySummaryLine {
  const MoneySummaryLine({
    required this.label,
    required this.amount,
    required this.currencyCode,
    this.isTotal = false,
  });

  final String label;
  final double amount;
  final String currencyCode;
  final bool isTotal;
}

class MoneySummaryCard extends StatelessWidget {
  const MoneySummaryCard({
    super.key,
    required this.lines,
    this.title,
    this.description,
    this.icon,
  });

  final List<MoneySummaryLine> lines;
  final String? title;
  final String? description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.flat,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || icon != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: colors.gold, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                ],
                if (title != null)
                  Expanded(
                    child: AppText(
                      title!,
                      variant: AppTextVariant.labelLarge,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          for (final line in lines) ...[
            if (line.isTotal && line != lines.first) ...[
              Divider(color: colors.borderSubtle, height: AppSpacing.xl),
            ],
            _MoneySummaryRow(line: line),
            if (!line.isTotal && line != lines.last)
              const SizedBox(height: AppSpacing.sm),
          ],
          if (description != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppText(
              description!,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _MoneySummaryRow extends StatelessWidget {
  const _MoneySummaryRow({required this.line});

  final MoneySummaryLine line;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = formatCurrency(line.amount, line.currencyCode);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AppText(
            line.label,
            variant: line.isTotal
                ? AppTextVariant.bodyMedium
                : AppTextVariant.labelMedium,
            color: line.isTotal ? colors.textPrimary : colors.textSecondary,
            fontWeight: line.isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        AmountText.fromText(
          value,
          size: line.isTotal ? AmountTextSize.medium : AmountTextSize.small,
          color: line.isTotal ? colors.gold : colors.textPrimary,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
