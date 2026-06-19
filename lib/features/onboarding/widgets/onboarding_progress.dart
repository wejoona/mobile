import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/flow_step_progress.dart';

/// Compatibility wrapper for product-onboarding progress.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) =>
      FlowStepProgress(currentStep: currentStep, totalSteps: totalSteps);
}
