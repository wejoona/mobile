import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';

class LimitProgressBar extends StatelessWidget {
  final double percentage;
  final bool isNearLimit;
  final bool isAtLimit;
  final double height;

  const LimitProgressBar({
    super.key,
    required this.percentage,
    this.isNearLimit = false,
    this.isAtLimit = false,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color getProgressColor() {
      if (isAtLimit) return AppColors.errorBase;
      if (isNearLimit) return AppColors.warningBase;
      return colors.gold;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: LinearProgressIndicator(
        value: percentage,
        backgroundColor: colors.borderSubtle,
        valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
        minHeight: height,
      ),
    );
  }
}
