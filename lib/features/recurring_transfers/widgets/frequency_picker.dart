import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/transfer_frequency.dart';

class FrequencyPicker extends StatelessWidget {
  const FrequencyPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TransferFrequency selected;
  final ValueChanged<TransferFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.recurringTransfers_frequency,
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: TransferFrequency.values.map((frequency) {
            final isSelected = selected == frequency;
            return GestureDetector(
              onTap: () => onChanged(frequency),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.gold500
                      : AppColors.slate,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.gold500
                        : AppColors.textSecondary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: AppText(
                  frequency.getDisplayName(locale),
                  variant: AppTextVariant.bodyMedium,
                  color: isSelected ? AppColors.obsidian : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
