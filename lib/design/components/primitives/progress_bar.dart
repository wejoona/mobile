import 'package:flutter/material.dart';

/// Animated horizontal progress bar.
class ProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final double borderRadius;
  final Duration animationDuration;
  final String? label;
  final bool showPercentage;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
    this.backgroundColor,
    this.borderRadius = 4,
    this.animationDuration = const Duration(milliseconds: 600),
    this.label,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = value.clamp(0.0, 1.0);
    final activeColor = color ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${(clamped * 100).round()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Container(color: bgColor),
                AnimatedFractionallySizedBox(
                  duration: animationDuration,
                  curve: Curves.easeOutCubic,
                  widthFactor: clamped,
                  child: Container(
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Segmented progress bar (like WhatsApp stories).
class SegmentedProgressBar extends StatelessWidget {
  final int totalSegments;
  final int completedSegments;
  final double height;
  final double spacing;

  const SegmentedProgressBar({
    super.key,
    required this.totalSegments,
    required this.completedSegments,
    this.height = 3,
    this.spacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(totalSegments, (i) {
        final isComplete = i < completedSegments;
        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.only(
              right: i < totalSegments - 1 ? spacing : 0,
            ),
            decoration: BoxDecoration(
              color: isComplete
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        );
      }),
    );
  }
}
