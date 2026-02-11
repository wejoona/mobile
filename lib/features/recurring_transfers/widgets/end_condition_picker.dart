import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/recurring_transfers/providers/create_recurring_transfer_provider.dart';

class EndConditionPicker extends StatelessWidget {
  const EndConditionPicker({
    super.key,
    required this.endCondition,
    required this.endDate,
    required this.occurrences,
    required this.onEndConditionChanged,
    required this.onEndDateChanged,
    required this.onOccurrencesChanged,
  });

  final EndCondition endCondition;
  final DateTime? endDate;
  final int? occurrences;
  final ValueChanged<EndCondition> onEndConditionChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final ValueChanged<int?> onOccurrencesChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.recurringTransfers_endCondition,
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: AppSpacing.sm),
        _buildOption(
          context,
          l10n,
          EndCondition.never,
          l10n.recurringTransfers_neverEnd,
          Icons.all_inclusive,
        ),
        SizedBox(height: AppSpacing.sm),
        _buildOption(
          context,
          l10n,
          EndCondition.afterOccurrences,
          l10n.recurringTransfers_afterOccurrences,
          Icons.repeat,
        ),
        if (endCondition == EndCondition.afterOccurrences) ...[
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.xl),
            child: SizedBox(
              width: 120,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: l10n.recurringTransfers_occurrencesCount,
                  filled: true,
                  fillColor: AppColors.elevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                initialValue: occurrences?.toString(),
                onChanged: (v) {
                  final count = int.tryParse(v);
                  onOccurrencesChanged(count);
                },
              ),
            ),
          ),
        ],
        SizedBox(height: AppSpacing.sm),
        _buildOption(
          context,
          l10n,
          EndCondition.untilDate,
          l10n.recurringTransfers_untilDate,
          Icons.event,
        ),
        if (endCondition == EndCondition.untilDate) ...[
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.xl),
            child: AppCard(
              variant: AppCardVariant.subtle,
              onTap: () => _selectEndDate(context, endDate),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.gold500, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    AppText(
                      endDate != null
                          ? _formatDate(endDate!)
                          : l10n.recurringTransfers_selectDate,
                      variant: AppTextVariant.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    AppLocalizations l10n,
    EndCondition condition,
    String label,
    IconData icon,
  ) {
    final isSelected = endCondition == condition;

    return GestureDetector(
      onTap: () => onEndConditionChanged(condition),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold500.withOpacity(0.1)
              : AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.gold500
                : AppColors.textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.gold500 : AppColors.textSecondary,
              size: 20,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(
                label,
                variant: AppTextVariant.bodyMedium,
                color: isSelected ? AppColors.gold500 : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.gold500,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectEndDate(BuildContext context, DateTime? initialDate) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)), // 2 years
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold500,
              surface: AppColors.slate,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      onEndDateChanged(date);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
