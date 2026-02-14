import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Progress indicator for onboarding steps
class OnboardingProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

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
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      width: isCompleted ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.gold500 : AppColors.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
