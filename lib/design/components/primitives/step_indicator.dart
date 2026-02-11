import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Step/progress indicator for multi-step flows.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor,
    this.inactiveColor,
  });

  final int totalSteps;
  final int currentStep;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = activeColor ?? colors.primary;
    final inactive = inactiveColor ?? colors.border;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isActive ? active : inactive,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
