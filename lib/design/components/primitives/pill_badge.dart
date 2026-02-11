import 'package:flutter/material.dart';

/// A small pill/badge for counts, labels, status tags.
class PillBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final bool isOutlined;

  const PillBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.isOutlined = false,
  });

  /// Success badge (green).
  factory PillBadge.success(String label) => PillBadge(
        label: label,
        backgroundColor: Colors.green.shade50,
        textColor: Colors.green.shade700,
      );

  /// Warning badge (orange).
  factory PillBadge.warning(String label) => PillBadge(
        label: label,
        backgroundColor: Colors.orange.shade50,
        textColor: Colors.orange.shade700,
      );

  /// Error badge (red).
  factory PillBadge.error(String label) => PillBadge(
        label: label,
        backgroundColor: Colors.red.shade50,
        textColor: Colors.red.shade700,
      );

  /// Info badge (blue).
  factory PillBadge.info(String label) => PillBadge(
        label: label,
        backgroundColor: Colors.blue.shade50,
        textColor: Colors.blue.shade700,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fg = textColor ?? theme.colorScheme.onPrimaryContainer;

    if (isOutlined) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: fg.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: fg,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: fg,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Notification count badge (small red circle with number).
class CountBadge extends StatelessWidget {
  final int count;
  final double size;

  const CountBadge({
    super.key,
    required this.count,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: count > 9 ? BorderRadius.circular(size / 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
