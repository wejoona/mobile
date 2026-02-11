import 'package:flutter/material.dart';

/// A horizontal step indicator for multi-step flows (onboarding, KYC, send).
class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double height;
  final double spacing;
  final Color? activeColor;
  final Color? inactiveColor;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.height = 4,
    this.spacing = 4,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? theme.colorScheme.primary;
    final inactive =
        inactiveColor ?? theme.colorScheme.surfaceContainerHighest;

    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: height,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? spacing : 0),
            decoration: BoxDecoration(
              color: isActive ? active : inactive,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        );
      }),
    );
  }
}

/// Dot-style step indicator.
class DotStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double dotSize;
  final double activeDotWidth;
  final double spacing;

  const DotStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.dotSize = 8,
    this.activeDotWidth = 24,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isActive ? activeDotWidth : dotSize,
          height: dotSize,
          margin: EdgeInsets.only(right: index < totalSteps - 1 ? spacing : 0),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}
