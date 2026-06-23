import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Compact progress indicator for auth and setup flows.
class FlowStepProgress extends StatelessWidget {
  const FlowStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  /// One-based current step.
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps,
        (index) => _buildStep(index + 1 <= currentStep),
      ),
    );
  }

  Widget _buildStep(bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      width: isCompleted ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.gold500
            : AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
