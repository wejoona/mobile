import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/bulk_payment.dart';
import '../../../utils/formatting.dart';

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
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: payment.isValid
            ? null
            : Border.all(
                color: AppColors.error,
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
                      ? AppColors.gold500.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Center(
                  child: AppText(
                    '$index',
                    variant: AppTextVariant.bodySmall,
                    color: payment.isValid ? AppColors.gold500 : AppColors.error,
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
                              ? AppColors.gold500
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      payment.description,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!payment.isValid && payment.error != null) ...[
                      SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: AppColors.error,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: AppText(
                                payment.error!,
                                variant: AppTextVariant.bodySmall,
                                color: AppColors.error,
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
