import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/execution_history.dart';

class ExecutionHistoryList extends StatelessWidget {
  const ExecutionHistoryList({
    super.key,
    required this.history,
  });

  final List<dynamic> history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: history.map((execution) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: execution.success
                          ? context.colors.success.withOpacity(0.2)
                          : context.colors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      execution.success ? Icons.check : Icons.close,
                      color: execution.success
                          ? context.colors.success
                          : context.colors.error,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          execution.success
                              ? l10n.recurringTransfers_executionSuccess
                              : l10n.recurringTransfers_executionFailed,
                          variant: AppTextVariant.bodyMedium,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        AppText(
                          '${execution.amount.toStringAsFixed(0)} ${execution.currency}',
                          variant: AppTextVariant.bodySmall,
                          color: context.colors.textSecondary,
                        ),
                        if (!execution.success && execution.errorMessage != null)
                          AppText(
                            execution.errorMessage!,
                            variant: AppTextVariant.bodySmall,
                            color: context.colors.error,
                          ),
                      ],
                    ),
                  ),
                  AppText(
                    _formatDate(execution.executedAt),
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
