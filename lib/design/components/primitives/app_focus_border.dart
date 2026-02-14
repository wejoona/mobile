import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Focus indicator component for accessibility (WCAG 2.4.7)
///
/// Provides visible focus indication with proper contrast ratios
/// Automatically adapts to theme and component size
///
/// Usage:
/// ```dart
/// AppFocuseBorder(
///   child: MyWidget(),
/// )
/// ```
class AppFocusBorder extends StatefulWidget {
  const AppFocusBorder({
    super.key,
    required this.child,
    this.borderRadius,
    this.focusColor,
    this.focusWidth = 2.0,
    this.offset = 2.0,
    this.autofocus = false,
    this.onFocusChange,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final Color? focusColor;
  final double focusWidth;
  final double offset;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;

  @override
  State<AppFocusBorder> createState() => _AppFocusBorderState();
}

class _AppFocusBorderState extends State<AppFocusBorder> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    widget.onFocusChange?.call(_isFocused);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveFocusColor = widget.focusColor ?? colors.gold;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(AppRadius.md),
          border: _isFocused
              ? Border.all(
                  color: effectiveFocusColor,
                  width: widget.focusWidth,
                )
              : null,
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: effectiveFocusColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
        padding: EdgeInsets.all(widget.offset),
        child: widget.child,
      ),
    );
  }
}

/// Focus indicator extension for easy wrapping
extension FocusIndicator on Widget {
  /// Wrap widget with focus indicator
  Widget withFocusIndicator({
    BorderRadius? borderRadius,
    Color? focusColor,
    double focusWidth = 2.0,
    double offset = 2.0,
  }) {
    return AppFocusBorder(
      borderRadius: borderRadius,
      focusColor: focusColor,
      focusWidth: focusWidth,
      offset: offset,
      child: this,
    );
  }
}

/// High contrast mode detector
class HighContrastDetector extends InheritedWidget {
  const HighContrastDetector({
    super.key,
    required this.isHighContrast,
    required super.child,
  });

  final bool isHighContrast;

  static bool of(BuildContext context) {
    final detector = context.dependOnInheritedWidgetOfExactType<HighContrastDetector>();
    return detector?.isHighContrast ?? false;
  }

  @override
  bool updateShouldNotify(HighContrastDetector oldWidget) {
    return isHighContrast != oldWidget.isHighContrast;
  }
}

/// Helper to detect high contrast mode from MediaQuery
class HighContrastHelper {
  HighContrastHelper._();

  /// Check if high contrast mode is enabled
  static bool isEnabled(BuildContext context) {
    return MediaQuery.highContrastOf(context);
  }

  /// Get focus indicator width based on contrast mode
  static double getFocusWidth(BuildContext context) {
    return isEnabled(context) ? 3.0 : 2.0;
  }

  /// Get focus indicator color with enhanced contrast if needed
  static Color getFocusColor(BuildContext context) {
    final colors = context.colors;
    final isHighContrast = isEnabled(context);

    if (isHighContrast) {
      // Use pure gold for maximum contrast
      return colors.isDark ? AppColors.gold300 : AppColors.gold700;
    }

    return colors.gold;
  }
}
