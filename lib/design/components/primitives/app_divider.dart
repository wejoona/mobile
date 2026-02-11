import 'package:flutter/material.dart';

/// Themed divider with optional label.
class AppDivider extends StatelessWidget {
  final String? label;
  final double thickness;
  final double indent;
  final double endIndent;

  const AppDivider({
    super.key,
    this.label,
    this.thickness = 0.5,
    this.indent = 0,
    this.endIndent = 0,
  });

  /// "OR" divider commonly used between options.
  const AppDivider.or({super.key})
      : label = 'OR',
        thickness = 0.5,
        indent = 0,
        endIndent = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.outlineVariant;

    if (label == null) {
      return Divider(
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        color: color,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Divider(thickness: thickness, color: color, indent: indent),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(thickness: thickness, color: color, endIndent: endIndent),
        ),
      ],
    );
  }
}
