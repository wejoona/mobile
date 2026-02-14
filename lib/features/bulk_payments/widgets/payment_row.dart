import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_payment.dart';
import 'package:usdc_wallet/utils/formatting.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class PaymentRow extends StatelessWidget {
  final BulkPayment payment;
  final int index;

  const PaymentRow({
    super.key,
    required this.payment,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: payment.isValid
            ? null
            : Border.all(
                color: context.colors.error,
                width: 1,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: payment.isValid
                      ? context.colors.gold.withOpacity(0.1)
                      : context.colors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: AppText(
                    '$index',
                    variant: AppTextVariant.bodySmall,
                    color: payment.isValid ? context.colors.gold : context.colors.error,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppText(
                            payment.phone,
                            variant: AppTextVariant.bodyMedium,
                          ),
                        ),
                        AppText(
                          Formatting.formatCurrency(payment.amount),
                          variant: AppTextVariant.titleMedium,
                          color: payment.isValid
                              ? context.colors.gold
                              : context.colors.textSecondary,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      payment.description,
                      variant: AppTextVariant.bodySmall,
                      color: context.colors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!payment.isValid && payment.error != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: context.colors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: context.colors.error,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: AppText(
                                payment.error!,
                                variant: AppTextVariant.bodySmall,
                                color: context.colors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
