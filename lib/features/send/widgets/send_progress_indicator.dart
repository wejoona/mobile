import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Run 357: Step progress indicator for the multi-step send flow
class SendProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const SendProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    this.stepLabels = const ['Destinataire', 'Montant', 'Confirmation', 'PIN'],
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Etape $currentStep sur $totalSteps',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: List.generate(totalSteps, (index) {
                final isActive = index <= currentStep;
                final isCurrent = index == currentStep;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < totalSteps - 1 ? AppSpacing.xs : 0,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: isCurrent ? 4 : 2,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.gold
                            : AppColors.elevated,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (currentStep < stepLabels.length)
              AppText(
                stepLabels[currentStep],
                style: AppTextStyle.labelSmall,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
