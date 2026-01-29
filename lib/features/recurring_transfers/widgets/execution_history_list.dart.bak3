import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/execution_history.dart';

class ExecutionHistoryList extends StatelessWidget {
  const ExecutionHistoryList({
    super.key,
    required this.history,
  });

  final List<ExecutionHistory> history;

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
                          ? AppColors.successBase.withOpacity(0.2)
                          : AppColors.errorBase.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      execution.success ? Icons.check : Icons.close,
                      color: execution.success
                          ? AppColors.successBase
                          : AppColors.errorBase,
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
                          color: AppColors.textSecondary,
                        ),
                        if (!execution.success && execution.errorMessage != null)
                          AppText(
                            execution.errorMessage!,
                            variant: AppTextVariant.bodySmall,
                            color: AppColors.errorBase,
                          ),
                      ],
                    ),
                  ),
                  AppText(
                    _formatDate(execution.executedAt),
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
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
