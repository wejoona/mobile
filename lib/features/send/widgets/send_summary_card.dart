import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

/// Run 356: Summary card shown on send confirmation screen
class SendSummaryCard extends StatelessWidget {
  final String recipientName;
  final String? recipientPhone;
  final double amount;
  final double fee;
  final String currency;
  final String? note;

  const SendSummaryCard({
    super.key,
    required this.recipientName,
    this.recipientPhone,
    required this.amount,
    this.fee = 0,
    this.currency = 'USDC',
    this.note,
  });

  double get total => amount + fee;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Resume du transfert: $amount $currency vers $recipientName',
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              // Recipient
              Row(
                children: [
                  UserAvatar(name: recipientName, size: 48),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(recipientName, style: AppTextStyle.labelLarge),
                        if (recipientPhone != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          AppText(
                            recipientPhone!,
                            style: AppTextStyle.bodySmall,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const AppDivider(),
              const SizedBox(height: AppSpacing.lg),
              // Amount breakdown
              InfoRow(label: 'Montant', value: '$amount $currency'),
              const SizedBox(height: AppSpacing.sm),
              InfoRow(
                label: 'Frais',
                value: fee > 0 ? '$fee $currency' : 'Gratuit',
              ),
              const SizedBox(height: AppSpacing.sm),
              const AppDivider(),
              const SizedBox(height: AppSpacing.sm),
              InfoRow(
                label: 'Total',
                value: '$total $currency',
              ),
              if (note != null && note!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                const AppDivider(),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Note',
                        style: AppTextStyle.labelSmall,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        note!,
                        style: AppTextStyle.bodyMedium,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
